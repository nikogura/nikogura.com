# Cross-Cloud Kubernetes Clusters with AWS IRSA and Talos Linux

# Requirements
1. An AWS Account
2. [Terraform](https://www.terraform.io/)
3. [Sidero Labs Talos Terraform Provider](https://registry.terraform.io/providers/siderolabs/talos/latest/docs)
4. [AWS CLI](https://aws.amazon.com/cli/)
5. [Dex](https://github.com/dexidp/dex)

# High Level Description

OIDC is, more and more, how things connect in a hybrid world.  Every cloud has it's own proprietary auth mechanisms, but OIDC is one of the better supported general mechanisms for connecting various things in a way that you can both avoid vendor lock-in, and retain complete control.

Without going too far into the weeds, OIDC is an auth protocol that may use a JWT(Json Web Token) and JWKS (Json Web Key Set) to perform authentication and authorization.  Kubernetes, by default, uses/ exposes JWT and JWKS endpoints to do it's thing internally.  You can connect these to the major cloud providers that support OIDC and voila, your k8s system is connected to your wider cloud infrastructure.

This is made possible by 2 pieces of information that are served up publicly on the internet.  The pieces are:

1. An OpenID Configuration, generally located at `/.well-known/openid-configuration`.
2. A JWKS usually located at `.well-known/jwks.json`, but really it can be anywhere, so long as it's in the place indicated by the OpenID Configuration.

That's pretty much it.

## Example OpenID Configuration

The following example comes from a [minikube](https://minikube.sigs.k8s.io/docs/) installation.  Note the "jwks_uri" field.

      {
         "issuer": "https://kubernetes.default.svc.cluster.local",
         "jwks_uri": "https://192.168.49.2:8443/openid/v1/jwks",
         "response_types_supported": [
           "id_token"
         ],
         "subject_types_supported": [
           "public"
         ],
         "id_token_signing_alg_values_supported": [
           "RS256"
         ]
      }

Here's a JWKS, again from `minikube`.

      {
        "keys": [
          {
            "use": "sig",
            "kty": "RSA",
            "kid": "rWyCX69kkYAI6c7elPmJHF_BqEF7j5kG0D_lr6o548I",
            "alg": "RS256",
            "n": "6E83bPQ7d5hs_ri6g3rzRVyy8AIyUuE45G6Kw-fAloJ_UJ8_PhcrS2u4T1XbZ87emglzDaOksBuALxOvZM7YnEA5RbRa1wPqG92OnQmIFmujbNSXB4N66z24WFg6UKa8fF4xJTmTwhEfm2DJ-2haDOJ18m4xWAuJF0mLqIjiRRT2eOAirYL9tC26vf_hNsy0Dlv5Uad5XsloaIXZOONLKVOAS-w_if-1d0ckahSU2erbBG2zIvhfKTWKiz4wPo7ev6GlxNVoBYqfQZMvPvwpFHtaFumb8u5zlWjngzqJRUOji2pBMdZWAmci19VVz0PY9ZkD2dgKvlNvmnEm1P5E7w",
            "e": "AQAB"
          }
        ]
      }

With these two files served up on the internet, a cloud provider such as AWS can validate that a given K8S Service Account JWT was created by a particular K8S cluster, and will provide temporary, expiring AWS credentials to the service account.  

These credentials (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY, etc) will then allow any workload being run under that Service Account to interact with AWS like any other software.  K8S puts these credentials into the environment, where they are picked up by the AWS SDK of your choice.  Everything _just works_.

*NB: Note the "id_token_signing_alg_values_supported" field in the OpenID Configuration.  RS256 is an old algorithm.  Many modern systems have moved away from RSA signing, but the big cloud providers have not.  For instance, with Talos Linux < 1.7.0, a modern, EC key and algorithm is used, but AWS doesn't support it.  Talos 1.7.0 and above use RS256 for signing JWT's precisely for this reason - wider interopability with legacy systems.*

* I can't tell you how frustrating it was to dig that little factoid out.  The error messages were totally unhelpful, and it took some sleuthing around looking at raw outputs from the EKS OpenID Configuration outputs before I spotted that they were all RS256, and I recalled that EC2 doesn't support newer keys.  Thanks a lot, Amazon.*


# Installation

1. Provision an AWS VPC
2. Run Dex
3. Customize Terraform
4. Apply Terraform
5. Output Talos Config
6. Update Kubectl and verify access
7. Update OIDC Files in S3
8. Apply ClusterRoleBinding
9. Verify Authentication Authorization

        # Source: k get --raw /.well-known/openid-configuration > openid-configuration
        # aws s3 cp openid-configuration s3://some-bucket/.well-known/openid-configuration
        # Dest: https://some-bucket.s3.us-east-1.amazonaws.com/.well-known/openid-configuration

        # Source: k get --raw /openid/v1/jwks > jwks.json
        # aws s3 cp jwks.json s3://some-bucket/.well-known/jwks.json
        # Dest: https://some-bucket.s3.us-east-1.amazonaws.com/.well-known/jwks.json

# Terraform Example Code

The following is an example of how to do it:

I called this cluster 'adam', because I had to call it something, and naming things is hard.  

I always assume I will need multiple clusters, hence unique names are essential.

*NB: I have included a domain name for the cluster nodes, but I have not included examples of DNS record resources. *

The Terraform:

        locals {
          cluster_adam_vpc_id                    = "some-vpc-id"
          cluster_adam_talos_version             = "v1.7.0"
          cluster_adam_aws_region                = "us-east-1"
          cluster_adam_arch                      = "amd64"
          cluster_adam_k8s_version               = "1.29.3"
          cluster_adam_cp_instance_size          = "m5.2xlarge"
          cluster_adam_worker_instance_size      = "m5.2xlarge"
          cluster_adam_oidc_issuer_url           = "https://dex.yourcompany.com"
          cluster_adam_oidc_client_id            = "e26fa09975029af5f03fb8ac7e0127"
          cluster_adam_oidc-ca-file              = "/etc/ssl/certs/ca-certificates.crt" // If the OIDC issuer uses a public CA, you can just use the linux default bundle.
          cluster_adam_oidc-username-claim       = "email"
          cluster_adam_oidc-groups-claim         = "groups"
          cluster_adam_service-account-issuer    = "https://some-bucket.s3.us-east-1.amazonaws.com"
          cluster_adam_service-account-jwks-uri  = "https://some-bucket.s3.us-east-1.amazonaws.com/.well-known/jwks.json"
          cluster_adam_oidc_bucket_name          = "some-bucket"
          cluster_adam_lb_subnet_id              = "subnet-id"
          cluster_adam_lb_internal               = false
          cluster_adam_lb_name                   = "your-cluster-name"
          cluster_adam_domain_name               = "your.domain.com"

          talos_azure_image_id                   = "/communityGalleries/siderolabs-c4d707c0-343e-42de-b597-276e4f7a5b0b/images/talos-x64/versions/1.7.0"

        }

        data "aws_ami" "talos-ami-adam" {
          most_recent = true
          filter {
            name   = "name"
            values = ["talos-${local.cluster_adam_talos_version}-${local.cluster_adam_aws_region}-${local.cluster_adam_arch}"]
          }
          owners = ["540036508848"] # Sidero Labs' AWS Account
        }

        resource "aws_lb" "apiserver-adam" {
          name                = local.cluster_adam_lb_name
          load_balancer_type  = "network"
          internal            = local.cluster_adam_lb_internal
          subnets = [
            local.cluster_adam_lb_subnet_id
          ]

          tags                = {
            Cluster = "adam"
          }
          security_groups     = [
            aws_security_group.cluster-adam-apiserver-lb.id,
          ]
        }

        resource "aws_security_group" "cluster-adam-apiserver-lb" {
          vpc_id = aws_vpc.main.id

          egress {
            description = "Egress everywhere"
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_blocks = ["0.0.0.0/0"]
          }

          ingress {
            description = "K8S API"
            from_port   = 6443
            to_port     = 6443
            protocol    = "tcp"
            cidr_blocks = [
              "0.0.0.0/0",
            ]
          }

          tags  = {
            Cluster = "adam"
          }
        }

        resource "aws_lb_listener" "apiserver-adam-6443" {
         load_balancer_arn  = aws_lb.apiserver-adam.arn
          port              = "6443"
          protocol          = "TCP"
          tags              = {
            Cluster = "adam"
          }

          default_action {
            type              = "forward"
            target_group_arn  = aws_lb_target_group.apiserver-adam-6443.arn
          }
        }

        resource "aws_lb_target_group" "apiserver-adam-6443" {
          name                = "apiserver-adam-6443"
          port                = 6443
          protocol            = "TCP"
          vpc_id              = local.cluster_adam_vpc_id
          proxy_protocol_v2   = false // not supported by k8s yet
          preserve_client_ip  = false  // must be false until ppv2 is supported
          target_type         = "instance"

          health_check {
            protocol            = "TCP"
            healthy_threshold   = 2
            unhealthy_threshold = 2
            interval            = 10
            port                = 6443
          }

          tags                = {
            Cluster = "adam"
          }
        }

        resource "aws_security_group" "cluster-adam-node" {
          vpc_id = aws_vpc.main.id
          tags   = {
            Cluster = "adam"
          }
        }

        # Allow access to the apiserver through the loadbalancer
        resource "aws_security_group_rule" "adam-apiserver" {
          type              = "ingress"
          from_port         = 6443
          to_port           = 6443
          protocol          = "TCP"
          security_group_id = aws_security_group.cluster-adam-node.id
          source_security_group_id = aws_security_group.cluster-adam-apiserver-lb.id
        }
         
        # Allow all ports between the nodes
        resource "aws_security_group_rule" "adam-ingress" {
          type                      = "ingress"
          from_port                 = 0
          to_port                   = 0
          protocol                  = "-1"
          security_group_id         = aws_security_group.cluster-adam-node.id
          source_security_group_id  = aws_security_group.cluster-adam-node.id
        }
         
        # Allow access to the Talos API from within the VPC
        resource "aws_security_group_rule" "adam-talos" {
          type              = "ingress"
          from_port         = 50000
          to_port           = 50000
          protocol          = "TCP"
          security_group_id = aws_security_group.cluster-adam-node.id
          cidr_blocks       = [
            aws_vpc.main.cidr_block,
          ]
        }

        # Open Egress from the cluster
        resource "aws_security_group_rule" "adam-egress" {
          type              = "egress"
          from_port         = 0
          to_port           = 0
          protocol          = "-1"
          cidr_blocks       = ["0.0.0.0/0"]
          security_group_id = aws_security_group.cluster-adam-node.id
        }


        resource "aws_instance" "adam-cp-1" {
          ami                     = data.aws_ami.talos-ami-adam.id
          instance_type           = local.cluster_adam_cp_instance_size
          subnet_id               = local.cluster_adam_lb_subnet_id
          vpc_security_group_ids  = [
            aws_security_group.cluster-adam-node.id
          ]

          tags                    = {
            Name    = "adam-cp-1"
            Cluster = "adam"
          }
        }

        resource "aws_lb_target_group_attachment" "adam-cp-1" {
          port              = 6443
          target_group_arn  = aws_lb_target_group.apiserver-adam-6443.arn
          target_id         = aws_instance.adam-cp-1.id
        }

        resource "aws_instance" "adam-cp-2" {
          ami                    = data.aws_ami.talos-ami-adam.id
          instance_type          = local.cluster_adam_cp_instance_size
          subnet_id              = local.cluster_adam_lb_subnet_id
          vpc_security_group_ids = [
            aws_security_group.cluster-adam-node.id
          ]

          tags                   = {
            Name    = "adam-cp-2"
            Cluster = "adam"
          }
        }

        resource "aws_lb_target_group_attachment" "adam-cp-2" {
          port              = 6443
          target_group_arn  = aws_lb_target_group.apiserver-adam-6443.arn
          target_id         = aws_instance.adam-cp-2.id
        }

        resource "aws_instance" "adam-cp-3" {
          ami                     = data.aws_ami.talos-ami-adam.id
          instance_type           = local.cluster_adam_cp_instance_size
          subnet_id               = local.cluster_adam_lb_subnet_id
          vpc_security_group_ids  = [
            aws_security_group.cluster-adam-node.id
          ]

          tags                    = {
            Name    = "adam-cp-3"
            Cluster = "adam"
          }
        }

        resource "aws_lb_target_group_attachment" "adam-cp-3" {
          port              = 6443
          target_group_arn  = aws_lb_target_group.apiserver-adam-6443.arn
          target_id         = aws_instance.adam-cp-3.id
        }

        output "cluster_adam_cp_addresses" {
          value = [
            aws_instance.adam-cp-1.private_ip,
            aws_instance.adam-cp-2.private_ip,
            aws_instance.adam-cp-3.private_ip,
          ]
        }

        output "cluster_adam_apiserver_url" {
          value = "https://${aws_lb.apiserver-adam.dns_name}:6443"
        }

        resource "talos_machine_secrets" "adam" {}

        data "talos_machine_configuration" "adam-cp" {
          cluster_name = "adam"
          machine_type = "controlplane"
          cluster_endpoint = "https://${aws_lb.apiserver-adam.dns_name}:6443"
          machine_secrets = talos_machine_secrets.adam.machine_secrets
        }

        data "talos_machine_configuration" "adam-worker" {
          cluster_name = "adam"
          machine_type = "worker"
          cluster_endpoint = "https://${aws_lb.apiserver-adam.dns_name}6443"
          machine_secrets = talos_machine_secrets.adam.machine_secrets
        }

        data "talos_client_configuration" "adam-admin" {
          cluster_name = "adam"
          client_configuration = talos_machine_secrets.adam.client_configuration
        }

        resource "talos_machine_configuration_apply" "adam-cp-1" {
          client_configuration        = talos_machine_secrets.adam.client_configuration
          machine_configuration_input = data.talos_machine_configuration.adam-cp.machine_configuration
          node                        = aws_instance.adam-cp-1.private_ip
          config_patches              = [
            yamlencode({
              machine = {
                install = {
                  disk = "/dev/xvda"  # Default for larger EC2 instances
                }
                network = {
                  hostname: "adam-cp-1.${local.cluster_adam_domain_name}" # amazon's default hostnames make support painful
                }
              },
              cluster = {
                allowSchedulingOnControlPlanes: true
                apiServer = {
                  extraArgs = {
                    oidc-issuer-url: local.cluster_adam_oidc_issuer_url
                    oidc-client-id: local.cluster_adam_oidc_client_id
                    oidc-ca-file: local.cluster_adam_oidc-ca-file
                    oidc-username-claim: local.cluster_adam_oidc-username-claim
                    oidc-groups-claim: local.cluster_adam_oidc-groups-claim
                    service-account-issuer: local.cluster_adam_service-account-issuer
                    service-account-jwks-uri: local.cluster_adam_service-account-jwks-uri
                  }
                }
              }
            })
          ]
        }

        resource "talos_machine_configuration_apply" "adam-cp-2" {
          client_configuration        = talos_machine_secrets.adam.client_configuration
          machine_configuration_input = data.talos_machine_configuration.adam-cp.machine_configuration
          node                        = aws_instance.adam-cp-2.private_ip
          config_patches              = [
            yamlencode({
              machine = {
                install = {
                  disk = "/dev/xvda"
                }
                network = {
                  hostname: "adam-cp-2.${local.cluster_adam_domain_name}"
                }
              },
              cluster = {
                allowSchedulingOnControlPlanes: true
                apiServer = {
                  extraArgs = {
                    oidc-issuer-url: local.cluster_adam_oidc_issuer_url
                    oidc-client-id: local.cluster_adam_oidc_client_id
                    oidc-ca-file: local.cluster_adam_oidc-ca-file
                    oidc-username-claim: local.cluster_adam_oidc-username-claim
                    oidc-groups-claim: local.cluster_adam_oidc-groups-claim
                    service-account-issuer: local.cluster_adam_service-account-issuer
                    service-account-jwks-uri: local.cluster_adam_service-account-jwks-uri
                  }
                }
              }
            })
          ]
        }

        resource "talos_machine_configuration_apply" "adam-cp-3" {
          client_configuration        = talos_machine_secrets.adam.client_configuration
          machine_configuration_input = data.talos_machine_configuration.adam-cp.machine_configuration
          node                        = aws_instance.adam-cp-3.private_ip
          config_patches              = [
            yamlencode({
              machine = {
                install = {
                  disk = "/dev/xvda"
                }
                network = {
                  hostname: "adam-cp-3.${local.cluster_adam_domain_name}"
                }
              },
              cluster = {
                allowSchedulingOnControlPlanes: true
                apiServer = {
                  extraArgs = {
                    oidc-issuer-url: local.cluster_adam_oidc_issuer_url
                    oidc-client-id: local.cluster_adam_oidc_client_id
                    oidc-ca-file: local.cluster_adam_oidc-ca-file
                    oidc-username-claim: local.cluster_adam_oidc-username-claim
                    oidc-groups-claim: local.cluster_adam_oidc-groups-claim
                    service-account-issuer: local.cluster_adam_service-account-issuer
                    service-account-jwks-uri: local.cluster_adam_service-account-jwks-uri
                  }
                }
              }
            })
          ]
        }

        resource "talos_machine_bootstrap" "adam-cp-1" {
          node                 = aws_instance.adam-cp-1.private_ip
          client_configuration = talos_machine_secrets.adam.client_configuration
          depends_on           = [
            talos_machine_configuration_apply.adam-cp-1
          ]
        }

        output "talos-config-adam" {
          value = data.talos_client_configuration.adam-admin.talos_config
          sensitive = true
        }

        # Worker Nodes
        #resource "aws_instance" "adam-worker-1" {
        #  ami = data.aws_ami.talos-ami-adam.id
        #  instance_type = local.cluster_adam_worker_instance_size
        #  subnet_id = local.cluster_adam_lb_subnet_id
        #  vpc_security_group_ids = [
        #    aws_security_group.cluster-adam-node.id
        #  ]
        #
        #  tags = {
        #    Name    = "adam-worker-1"
        #    Cluster = "adam"
        #  }
        #}
        #
        #resource "talos_machine_configuration_apply" "adam-worker-1" {
        #  client_configuration        = talos_machine_secrets.adam.client_configuration
        #  machine_configuration_input = data.talos_machine_configuration.adam-worker.machine_configuration
        #  node                        = aws_instance.adam-worker-1.private_ip
        #  config_patches              = [
        #    yamlencode({
        #      machine = {
        #        install = {
        #          disk = "/dev/xvda"
        #        }
        #        network = {
        #          hostname: "adam-worker-1.${local.cluster_adam_domain_name}"
        #        }
        #      }
        #    })
        #  ]
        #}

        # You could easily run this cluster cross-cloud if that's your pleasure
        #resource "azurerm_resource_group" "adam" {
        #  name      = "adam"
        #  location  = var.az_location
        #}
        #
        #resource "azurerm_network_interface" "adam-worker-2" {
        #  name                = "adam-worker-2"
        #  location            = azurerm_resource_group.adam.location
        #  resource_group_name = azurerm_resource_group.adam.name
        #
        #  ip_configuration {
        #    name                          = "internal"
        #    subnet_id                     = azurerm_subnet.private_subnet_1.id
        #    private_ip_address_allocation = "Static"
        #    private_ip_address_version    = "IPv4"
        #    private_ip_address            = "10.60.48.10"
        #  }
        #}
        #
        #resource "azurerm_linux_virtual_machine" "adam-worker-2" {
        #  name                = "adam-worker-2"
        #  resource_group_name = azurerm_resource_group.adam.name
        #  location            = azurerm_resource_group.adam.location
        #  size                = "Standard_D2s_v4"
        #
        #  admin_username        = "nik"
        #  network_interface_ids = [
        #    azurerm_network_interface.adam-worker-2.id
        #  ]
        #
        #  admin_ssh_key {
        #    public_key = file("~/.ssh/id_rsa.pub")
        #    username   = "nik"
        #  }
        #
        #  os_disk {
        #    caching              = "ReadWrite"
        #    storage_account_type = "Standard_LRS"
        #    disk_size_gb         = 10
        #  }
        #
        #  source_image_id = local.talos_azure_image_id
        #}
        #
        #resource "talos_machine_configuration_apply" "adam-worker-2" {
        #  client_configuration        = talos_machine_secrets.adam.client_configuration
        #  machine_configuration_input = data.talos_machine_configuration.adam-worker.machine_configuration
        #  node                        = azurerm_network_interface.adam-worker-2.private_ip_address
        #  config_patches              = [
        #    yamlencode({
        #      machine = {
        #        install = {
        #          disk = "/dev/xvda"
        #        }
        #      }
        #    })
        #  ]
        #}

        # Bucket for hosting the OIDC Configuration for for the cluster.
        # This is needed in order to register the cluster as an OIDC Identity Provider with your AWS account, which is necessary for IRSA
        # The info is available in the k8s apiserver, but for AWS to use it, it has to be available on the internet without authentication.  This sounds scary, but it's how all OIDC Identity Providers in AWS work.

        resource "aws_s3_bucket" "cluster-adam-oidc" {
          bucket = local.cluster_adam_oidc_bucket_name

        }

        resource "aws_s3_bucket_ownership_controls" "cluster-adam-oidc" {
          bucket = aws_s3_bucket.cluster-adam-oidc.id
          rule {
            object_ownership = "BucketOwnerPreferred"
          }
        }

        resource "aws_s3_bucket_public_access_block" "cluster-adam-oidc" {
          bucket = aws_s3_bucket.cluster-adam-oidc.id
          block_public_acls       = false
          block_public_policy     = false
          ignore_public_acls      = false
          restrict_public_buckets = false
        }


        resource "aws_s3_bucket_policy" "cluster-adam-oidc" {
          bucket = aws_s3_bucket.cluster-adam-oidc.bucket

          policy = jsonencode({
            Version = "2012-10-17",
            Statement = [
              {
                Effect = "Allow",
                Principal = "*",
                Action = "s3:GetObject",
                Resource = "${aws_s3_bucket.cluster-adam-oidc.arn}/*",
              },
            ],
          })

          depends_on = [
            aws_s3_bucket.cluster-adam-oidc,
            aws_s3_bucket_ownership_controls.cluster-adam-oidc,
            aws_s3_bucket_public_access_block.cluster-adam-oidc,
          ]
        }

        # Once the bucket exists, it needs to be filled with 2 files:

        # Source: k get --raw /.well-known/openid-configuration > openid-configuration
        # aws s3 cp openid-configuration s3://some-bucket/.well-known/openid-configuration
        # Dest: https://some-bucket.s3.us-east-1.amazonaws.com/.well-known/openid-configuration

        # Source: k get --raw /openid/v1/jwks > jwks.json
        # aws s3 cp jwks.json s3://some-bucket/.well-known/jwks.json
        # Dest: https://some-bucket.s3.us-east-1.amazonaws.com/.well-known/jwks.json

        # Read the cert for the s3 bucket so we can extract the thumbprint, even though AWS doesn't require a thumprint for s3, terraform won't apply it without it.  Thankfully, terraform will look up the cert, and extract the thumbprint.
        data "tls_certificate" "adam-bucket" {
          url = "https://${aws_s3_bucket.cluster-adam-oidc.bucket_regional_domain_name}"
        }

        # Setup the OIDC Identity Provider
        resource "aws_iam_openid_connect_provider" "adam" {
          url             = "https://${aws_s3_bucket.cluster-adam-oidc.bucket_regional_domain_name}"
          client_id_list  = ["sts.amazonaws.com"]
          thumbprint_list = [data.tls_certificate.adam-bucket.certificates[0].sha1_fingerprint]
        }

        # Role to test IRSA
        resource "aws_iam_role" "irsa-test" {
          name = "irsa-test"

          assume_role_policy = jsonencode({
            "Version" : "2012-10-17",
            "Statement" : [
              {
                "Effect" : "Allow",
                "Principal" : {
                  "Federated" : aws_iam_openid_connect_provider.adam.arn,
                },
                "Action" : "sts:AssumeRoleWithWebIdentity",
                "Condition" : {
                  "StringEquals" : {
                    "${trimprefix(aws_iam_openid_connect_provider.adam.url, "https://")}:sub" : "system:serviceaccount:kube-system:test",
                    "${trimprefix(aws_iam_openid_connect_provider.adam.url, "https://")}:aud" : "sts.amazonaws.com",
                  }
                }
              }
            ]
          })
        }

        # Role for EBS CSI
        resource "aws_iam_role" "adam-csi" {
          name = "adam-csi"

          assume_role_policy = jsonencode({
            "Version" : "2012-10-17",
            "Statement" : [
              {
                "Effect" : "Allow",
                "Principal" : {
                  "Federated" : aws_iam_openid_connect_provider.adam.arn,
                },
                "Action" : "sts:AssumeRoleWithWebIdentity",
                "Condition" : {
                  "StringEquals" : {
                    "${trimprefix(aws_iam_openid_connect_provider.adam.url, "https://")}:sub" : "system:serviceaccount:kube-system:ebs-csi-controller-sa",
                    "${trimprefix(aws_iam_openid_connect_provider.adam.url, "https://")}:aud" : "sts.amazonaws.com",
                  }
                }
              }
            ]
          })
        }

        resource "aws_iam_role_policy_attachment" "eks-csi-adam" {
          policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
          role       = aws_iam_role.adam-csi.name
        }
