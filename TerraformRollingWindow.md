# Auto Updating AMI's on a Rolling Window with Terraform

So, I recently had a connundrum.  I want my AWS EC2 ASG's to continuously update without manual intervention, but I don't want to 'poison' a launch config with a bad AMI image and cause a prod outage when the ASG eventually scales up.

One idea I had was to pre-build my AMI's, and pre-test the snot out of them before I used them in staging or production.  Duh, right?  Sadly, the environments I have are not the enviornments I want.  While I do want to achieve the blessed nirvana of being able to spin up new environments 'just cos' test them, and then let them vanish back into the ether, I'm a long way from that enlightened state.  There are too many tentacles in this legacy octopus code.  _sigh_.

Instead, I'm forced to rely on my staging enviornment to catch problems.  While not perfect, that staging env has been good enough to test prod deploys since before I joined this project.  If an AMI has been running in my staging environment without issues for a week or two, the AMI is probably good to go.

Terraform, however, allows me a 'latest' on it's AMI lookup, but not a 'latest before date X'.  What's a guy to do?

Here's what I came up with.  It's not particularly pretty, but it appears to work.


First, the basics:

        terraform {
        required_version = ">= 0.12"
        }

        provider "aws" {
        region  = "us-east-1"
        }

Then we define the owner of the AMI, and a pattern for the name.  In this case the owner is Canonical, and the image is Ubuntu.

        variable "ami_owner" {
            description = "AWS Account number used to look up AMI's."
            default = "099720109477"
        }

        variable "ami_name" {
            description = "AMI name pattern used to look up AMI's"
            default = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
        }

Next, we pull a list of the images

        data "aws_ami_ids" "bases" {
            filter {
                name   = "name"
                values = [var.ami_name]
            }

            filter {
                name   = "virtualization-type"
                values = ["hvm"]
            }

            owners = [var.ami_owner]
        }

Terraform is funny.  I can get a list of the ID's, but it's just a bunch of strings.  I have to look up the actual AMI's themselves thusly:

        data "aws_ami" "base" {
            count = length(data.aws_ami_ids.bases.ids)
            owners = [var.ami_owner]
            filter {
                name = "image-id"
                values = [data.aws_ami_ids.bases.ids["${count.index}"]]
            }
        }

Now I can get down and dirty.  We use `locals` to declare local variables I can use later in actual resources.

Where this gets really wild is, since I can't convert to unix time, and I can only use operatros like '<' on numbers, I have to 'format' the numbers in such a way that I can do a purely numeric comparison on them to build my window.

Then I can sort the keys, which works in lexicographic order - and turns out just fine given the numeric dates, and reverse it, cos I want the latest.

Finally I can pull the first element off the numeric list and pull lookup the ami id of that element.  Voila!

        locals {
            // window - 2 weeks ago in hours
            time_window = "-336h"

            // 2 weeks prior to the moment we run
            two_weeks_ago = formatdate("YYYYMMDDhhmmss", timeadd(timestamp(), local.time_window))

            // all images
            all_amis = {for i in data.aws_ami.base : formatdate("YYYYMMDDhhmmss", i.creation_date) => i.id}

            // images more than 2 weeks old
            older_amis = {for i in data.aws_ami.base : i.creation_date => i.id if formatdate("YYYYMMDDhhmmss", i.creation_date) < formatdate("YYYYMMDDhhmmss", timeadd(timestamp(), local.time_window))}

            dates = reverse(sort(keys(local.older_amis)))

            latest_date = local.dates[0]

            ami_id = local.older_amis[local.latest_date]

        }

I make outputs so I can see what I did:

        output "timeWindow" {
            value = local.time_window
        }

        output "twoWeeksAgo" {
            value = local.two_weeks_ago
        }

        output "allAmis" {
            value = local.all_amis
        }

        output "olderAmis" {
            value = local.older_amis
        }

        output "ami_id" {
            value = local.ami_id
        }

Run `terraform apply` on this  and you get something like:

        Outputs:

        allAmis = {
        "20180426220041" = "ami-7ad76705"
        "20180522173154" = "ami-432eb53c"
        "20180613234855" = "ami-85f9b8fa"
        "20180622194657" = "ami-5cc39523"
        "20180725160717" = "ami-b04847cf"
        "20180807104617" = "ami-920b10ed"
        "20180815001804" = "ami-0b425589c7bb7663d"
        "20180828123510" = "ami-07917569e2c4a2b6a"
        "20180912210417" = "ami-0ac019f4fcb7cb7e6"
        "20181013151116" = "ami-0977029b5b13f3d08"
        "20181106153828" = "ami-05aa248bfb1c99d0f"
        "20181126175259" = "ami-0d2505740b82f7948"
        "20181203192256" = "ami-0edd3706ab2e952c4"
        "20190117172225" = "ami-0b86cfbff176b7d3a"
        "20190123024731" = "ami-012fd5eb46f56731f"
        "20190210210246" = "ami-07073342279f98d28"
        "20190213124822" = "ami-0a313d6098716f372"
        "20190321160109" = "ami-07025b83b4379007e"
        "20190403221623" = "ami-0fba9b33b5304d8b4"
        "20190501114518" = "ami-0273df992a343e0d6"
        "20190515091552" = "ami-024a64a6685d05041"
        "20190531214333" = "ami-079f96ce4a4a7e1c7"
        "20190618052823" = "ami-095192256fe1477ad"
        "20190627214607" = "ami-026c8acd92718196b"
        "20190725194907" = "ami-07d0cf3af28718ef8"
        "20190819181119" = "ami-064a0193585662d74"
        "20190912044329" = "ami-024582e76075564db"
        "20190918222933" = "ami-05ecb1463f8f1ee4b"
        "20191002232841" = "ami-04b9e92b5572fa0d1"
        "20191010221339" = "ami-0607bfda7f358db2f"
        "20191021222116" = "ami-0d5ae5525eb033d0a"
        "20191113192803" = "ami-00a208c7cdba991ea"
        "20200115003046" = "ami-07ebfd5b3428b6f4d"
        "20200204185151" = "ami-046842448f9e74e7d"
        "20200312205548" = "ami-0238c6e72a7e906fc"
        "20200317210532" = "ami-055df5de4f42cf331"
        "20200324205616" = "ami-0a4f4704a9146742a"
        "20200409164413" = "ami-085925f297f89fce1"
        "20200507134600" = "ami-05801d0a3c8e4c443"
        "20200611211230" = "ami-025201fa53cf4d031"
        "20200611213648" = "ami-064fc5eec45384288"
        "20200611220538" = "ami-0ac80df6eff0e70b5"
        "20200710160608" = "ami-0dc45e3d9be6ab7b5"
        "20200716200445" = "ami-03a2cbdcd9e7d1955"
        "20200730152850" = "ami-07df16d0682f1fa59"
        "20200810202931" = "ami-0bcc094591f354be2"
        "20200824172451" = "ami-0c34018d0aabaef93"
        "20200903194723" = "ami-06b263d6ceff0b3dd"
        "20200908074438" = "ami-0817d428a6fb68645"
        "20200917161755" = "ami-06b33ea0e4b6334bc"
        "20200923231125" = "ami-013da1cc4ae87618c"
        "20201014160212" = "ami-038e35de01603d84e"
        "20201026191624" = "ami-00ddb0e5626798373"
        "20201112195935" = "ami-08b277333b9511393"
        "20201123222013" = "ami-0b893eef6e21b60a1"
        "20201201195255" = "ami-01c132a30955dafbb"
        "20201211122251" = "ami-053adf54573f777cf"
        "20210105200639" = "ami-0d0032af1da6905c7"
        "20210114205942" = "ami-01101ef9882f9c4bb"
        "20210120170000" = "ami-007e8beb808004fdc"
        "20210128195439" = "ami-02fe94dee086c0c37"
        }
        ami_id = ami-007e8beb808004fdc
        olderAmis = {
        "2018-04-26T22:00:41.000Z" = "ami-7ad76705"
        "2018-05-22T17:31:54.000Z" = "ami-432eb53c"
        "2018-06-13T23:48:55.000Z" = "ami-85f9b8fa"
        "2018-06-22T19:46:57.000Z" = "ami-5cc39523"
        "2018-07-25T16:07:17.000Z" = "ami-b04847cf"
        "2018-08-07T10:46:17.000Z" = "ami-920b10ed"
        "2018-08-15T00:18:04.000Z" = "ami-0b425589c7bb7663d"
        "2018-08-28T12:35:10.000Z" = "ami-07917569e2c4a2b6a"
        "2018-09-12T21:04:17.000Z" = "ami-0ac019f4fcb7cb7e6"
        "2018-10-13T15:11:16.000Z" = "ami-0977029b5b13f3d08"
        "2018-11-06T15:38:28.000Z" = "ami-05aa248bfb1c99d0f"
        "2018-11-26T17:52:59.000Z" = "ami-0d2505740b82f7948"
        "2018-12-03T19:22:56.000Z" = "ami-0edd3706ab2e952c4"
        "2019-01-17T17:22:25.000Z" = "ami-0b86cfbff176b7d3a"
        "2019-01-23T02:47:31.000Z" = "ami-012fd5eb46f56731f"
        "2019-02-10T21:02:46.000Z" = "ami-07073342279f98d28"
        "2019-02-13T12:48:22.000Z" = "ami-0a313d6098716f372"
        "2019-03-21T16:01:09.000Z" = "ami-07025b83b4379007e"
        "2019-04-03T22:16:23.000Z" = "ami-0fba9b33b5304d8b4"
        "2019-05-01T11:45:18.000Z" = "ami-0273df992a343e0d6"
        "2019-05-15T09:15:52.000Z" = "ami-024a64a6685d05041"
        "2019-05-31T21:43:33.000Z" = "ami-079f96ce4a4a7e1c7"
        "2019-06-18T05:28:23.000Z" = "ami-095192256fe1477ad"
        "2019-06-27T21:46:07.000Z" = "ami-026c8acd92718196b"
        "2019-07-25T19:49:07.000Z" = "ami-07d0cf3af28718ef8"
        "2019-08-19T18:11:19.000Z" = "ami-064a0193585662d74"
        "2019-09-12T04:43:29.000Z" = "ami-024582e76075564db"
        "2019-09-18T22:29:33.000Z" = "ami-05ecb1463f8f1ee4b"
        "2019-10-02T23:28:41.000Z" = "ami-04b9e92b5572fa0d1"
        "2019-10-10T22:13:39.000Z" = "ami-0607bfda7f358db2f"
        "2019-10-21T22:21:16.000Z" = "ami-0d5ae5525eb033d0a"
        "2019-11-13T19:28:03.000Z" = "ami-00a208c7cdba991ea"
        "2020-01-15T00:30:46.000Z" = "ami-07ebfd5b3428b6f4d"
        "2020-02-04T18:51:51.000Z" = "ami-046842448f9e74e7d"
        "2020-03-12T20:55:48.000Z" = "ami-0238c6e72a7e906fc"
        "2020-03-17T21:05:32.000Z" = "ami-055df5de4f42cf331"
        "2020-03-24T20:56:16.000Z" = "ami-0a4f4704a9146742a"
        "2020-04-09T16:44:13.000Z" = "ami-085925f297f89fce1"
        "2020-05-07T13:46:00.000Z" = "ami-05801d0a3c8e4c443"
        "2020-06-11T21:12:30.000Z" = "ami-025201fa53cf4d031"
        "2020-06-11T21:36:48.000Z" = "ami-064fc5eec45384288"
        "2020-06-11T22:05:38.000Z" = "ami-0ac80df6eff0e70b5"
        "2020-07-10T16:06:08.000Z" = "ami-0dc45e3d9be6ab7b5"
        "2020-07-16T20:04:45.000Z" = "ami-03a2cbdcd9e7d1955"
        "2020-07-30T15:28:50.000Z" = "ami-07df16d0682f1fa59"
        "2020-08-10T20:29:31.000Z" = "ami-0bcc094591f354be2"
        "2020-08-24T17:24:51.000Z" = "ami-0c34018d0aabaef93"
        "2020-09-03T19:47:23.000Z" = "ami-06b263d6ceff0b3dd"
        "2020-09-08T07:44:38.000Z" = "ami-0817d428a6fb68645"
        "2020-09-17T16:17:55.000Z" = "ami-06b33ea0e4b6334bc"
        "2020-09-23T23:11:25.000Z" = "ami-013da1cc4ae87618c"
        "2020-10-14T16:02:12.000Z" = "ami-038e35de01603d84e"
        "2020-10-26T19:16:24.000Z" = "ami-00ddb0e5626798373"
        "2020-11-12T19:59:35.000Z" = "ami-08b277333b9511393"
        "2020-11-23T22:20:13.000Z" = "ami-0b893eef6e21b60a1"
        "2020-12-01T19:52:55.000Z" = "ami-01c132a30955dafbb"
        "2020-12-11T12:22:51.000Z" = "ami-053adf54573f777cf"
        "2021-01-05T20:06:39.000Z" = "ami-0d0032af1da6905c7"
        "2021-01-14T20:59:42.000Z" = "ami-01101ef9882f9c4bb"
        "2021-01-20T17:00:00.000Z" = "ami-007e8beb808004fdc"
        }
        timeWindow = -336h
        twoWeeksAgo = 20210125214712

Q.E.D 


