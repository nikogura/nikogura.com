# Dynamic Binary Toolkit: Tools that automatically keep themselves up to date!

## Inevitability of Change

Updates suck.  There, I said it.

If you want a secure, reliable system, you *have* to keep it up to date.  Right?  We all know this.

But the update itself is change, and change is scary, cos change breaks things.

But *not changing* is also change, because everything else around you is constantly changing and evolving.  Even if your code hasn't changed by a single character, the system around it has likely changed.  If you've got any sort of security or compliance folks breathing down your back, not being up to date on your patches and versions is a big problem.

So what do we do about it?  Well, maybe in a perfect world, everyone would be a conscientious and whollistically minded professional with a big picture security mindset and yet still retain enough focus to perform in their own tightly focused area of expertise.  Yeah, maybe.  While you're at it, you might as well ask for a pony.  I've also got a bridge to sell you.

There's always going to be some tension between stability and upgrades, but again, given the rapidly evolving landscape, it's inevitable and you're going to have to deal with it.

## Automatic Updates

What we need is a way of keeping things up to date automatically, since a whole cross section of users are just *not* going to do it manually.  It'd be great if they did, but we have to draw a clear line between what we can do via technology, and what we have to accomplish by winning hearts and minds.

So, a tool that automatically updates itself then.  That seems rather Matrix like.  Actually, it turns out the tools have been there in Unix for quite a while.

In short, here's what we need to do:

1. [Find the latest version.](#find-the-latest-version)

2. [Determine if we're actually on the latest.](#determine-if-the-current-version-is-the-latest)

3. [If not, download the latest.](#download-the-latest)

4. [Make darn tootin' what we downloaded is gonna work.](#verify-the-latest)

5. [Move the latest into place where the code that spawned this process originally resided.](#replace-the-current-with-the-latest)

6. [Pull a 'Single White Female' on ourselves, and exec the new binary with the original arguments, and then carry on about our business.](#re-execute-new-binary-with-original-arguments)
    
    
## How it's Done

I'll share examples from some Go code.  I stored all my artifacts in Artifactory, but you can do so in any sort of web-available archive.

To work, you need to store the files, but also the detatched checksums and signatures of the file.

Artifactory gave me the following for free.  If I uploaded something called 'foo', to a repo I imaginatively call 'repo', I could count on:

    https://host/artifactory/repo/${version}/${os}/${arch}/foo
    
    https://host/artifactory/repo/${version}/${os}/${arch}/foo.md5
    
    https://host/artifactory/repo/${version}/${os}/${arch}/foo.sha1
    
I also generate a detatched signature as part of the publishing process and source it alongside the binary at:

    https://host/artifactory/repo/${version}/${os}/${arch}/foo.asc
    
In this setup I have to trust that if it's in the expected artifactory repo, I'll trust it.  You gotta trust someone.

### Find the Latest Version

I used [Sematic Versioning](https://semver.org/).  It's simple, it's human readable.  Go has this interesting git based dependency mechanism, and it's cool, but it's also **not** exactly human readable or friendly.

So I spider the repo at 'https://host/artifactory/repo/'  and find all the  version links with:

    func FetchVersions(repositoryUrl string, toolName string) (versions []string, err error) {
        uri := fmt.Sprintf("%s/%s/", repositoryUrl, toolName)

        resp, err := http.Get(uri)

        if err != nil {
            error = errors.Wrap(err, fmt.Sprintf("failed to find versions for  %q in repo %q: %s", toolName, uri, err))
            return versions, err
        }

        if resp != nil {
            versions = ParseVersionResponse(resp)

            defer resp.Body.Close()

        }

        return versions, err
    }

    func ParseVersionResponse(resp *http.Response) (versions []string) {
        parser := html.NewTokenizer(resp.Body)

        for {
            tt := parser.Next()

            switch {
            case tt == html.ErrorToken:
                return
            case tt == html.StartTagToken:
                t := parser.Token()
                isAnchor := t.Data == "a"
                if isAnchor {
                    for _, a := range t.Attr {
                        if a.Key == "href" {
                            if a.Val != "../" {
                                // any links beyond the 'back' link will be versions
                                // trim the trailing slash so we get actual semantic versions
                                versions = append(versions, strings.TrimRight(a.Val, "/"))
                            }
                        }
                    }
                }
            }
        }

        return versions
    }

Now I have a list of versions, so I find the latest one:

    func LatestVersion(versions []string) (latest string) {
        for _, version := range versions {
            if latest == "" {
                latest = version
            } else {

                if VersionAIsNewerThanB(latest, version) {
                } else {
                    latest = version
                }
            }
        }

        return latest
    }

    // VersionIsNewerThan  Returns true if Semantic Version string v1 is newer (higher numbers) than Semantic Version string v2
    func VersionAIsNewerThanB(a string, b string) (result bool) {
        aParts, err := SemverParse(a)
        if err != nil {
            return false
        }

        bParts, err := SemverParse(b)
        if err != nil {
            return true
        }

        major := Spaceship(aParts[0], bParts[0])

        if major == 0 {
            minor := Spaceship(aParts[1], bParts[1])

            if minor == 0 {
                patch := Spaceship(aParts[2], bParts[2])

                if patch == 0 {
                    return false
                } else {
                    if patch > 0 {
                        return true
                    } else {
                        return false
                    }
                }

            } else {
                if minor > 0 {
                    return true
                } else {
                    return false
                }
            }

        } else {
            if major > 0 {
                return true
            } else {
                return false
            }
        }

        return false
    }
    
    // SenverParse  Breaks the parts of the semantic version into pieces and returns a slice with each piece in a discrete bucket
    func SemverParse(version string) (parts []int, err error) {

        stringParts := strings.Split(version, ".")

        for _, part := range stringParts {
            number, err := strconv.Atoi(part)
            if err != nil {
                return parts, err
            }

            parts = append(parts, number)
        }

        return parts, err
    }


    // Spaceship(a, b)  A very simple implementation of a useful operator that go seems not to have.
    // returns 1 if a > b, -1 if a < b, and 0 if a == b
    func Spaceship(a int, b int) int {
        if a < b {
            return -1

        } else {
            if a > b {
                return 1
            } else {
                return 0
            }
        }
    }

Then, once I find the latest version, I get it's checksum from :

    https://host/artifactory/repo/${version}/linux/x86_64/foo.sha1

### Determine if the Current Version is the Latest

Now that I have the checksum of the latest version, I can determine if that's what I have on disk.  In one fell swoop I can detect whether I have the right version, and if my copy is intact.

    func VerifyBinaryChecksum(toolFile string, expected string) (success bool, err error) {
        checksum, err := FileSha1(toolFile)
        if err != nil {
            success = false
            return success, err
        }

        if checksum == expected {
            success = true
            return success, err
        } else {
            success = false
            return success, err
        }
        return success, err
    }
    
If it doesn't check out, for whatever reason, it's no good.  I don't really care whether I'm on an old version, or my version is corrupted.  Either way I need the latest, so I move on.

### Download the Latest

I'm not going to bother showing the code to download a file from a url.  That's pretty basic stuff.  I assume the reader knows a round dozen ways to accomplish it.

What I do do, however, is download it to a temporary directory so I can take a look at it.  I also download it's signature, and the public key of the keypair I'm using for signing.

In that temp dir, I'm expecting to find:

    foo
    
    foo.sha1
    
    foo.asc
    
    pubkey

###  Verify the Latest

I verify its checksum as above, and also its signature:

    func VerifyBinarySignature(toolName string, tmpDir string) (success bool, err error) {
        sigFileName := fmt.Sprintf("%s/%s.asc", tmpDir, toolName)
        signature, err := os.Open(sigFileName)

        if err != nil {
            return false, err
        }

        pubkeyFileName := fmt.Sprintf("%s/%s", tmpDir, "pubkey")

        keyRingReader, err := os.Open(pubkeyFileName)

        if err != nil {
            return false, err
        }

        target, err := os.Open(fmt.Sprintf("%s/%s", tmpDir, toolName))

        if err != nil {
            return false, err
        }

        keyring, err := openpgp.ReadArmoredKeyRing(keyRingReader)
        if err != nil {
            return false, err
        }

        entity, err := openpgp.CheckArmoredDetachedSignature(keyring, target, signature)

        if err != nil {
            return false, err
        }

        if entity != nil {
            return true, err
        }

        return false, err
    }
    
The OpenPGP libraries are kind of odd, they don't return thumbs up or thumbs down.  They return a the signing Entity if the signature checks out.  

I suppose that's useful if you have a ton of keys in your 'keyring'.  In this case, I do not.

### Replace the Current With the Latest

Now that I'm pretty sure everthing is what I think it is, I can simply move it into place with a simple:


		err = os.Rename(binaryFile, DEFAULT_FILE_LOCATION)
		if err != nil {
			err = errors.Wrap(err, "failed moving new binary into place")
			return err
		}

		err = os.Chmod(DEFAULT_FILE_LOCATION, 0755)
		if err != nil {
			err = errors.Wrap(err, "failed to make double sure new binary is executable")
			return err
		}
		
Note I'm making sure the new file is executable.  I've got one shot at this, and it has to *just work*.  If it requires a second try, I've failed, and I'm probably in a weird half state that will confuse my users and require direct interaction.  Yuck.

### Re Execute New Binary with Original Arguments

I'm blown away that this is actually this simple:

		fmt.Fprintln(os.Stderr, "Re- executing new version with original args.  Pretty cool huh?\n\n")

		syscall.Exec("/usr/local/bin/igor", os.Args, os.Environ())
		
Under the surface, Go is calling [execve](https://en.wikipedia.org/wiki/Exec_(system_call)).  For those who don't wish to follow that link, it says:

*"In computing, exec is a functionality of an operating system that runs an executable file in the context of an already existing process, replacing the previous executable. This act is also referred to as an overlay. It is especially important in Unix-like systems, although other operating systems implement it as well. Since a new process is not created, the original process identifier (PID) does not change, but the machine code, data, heap, and stack of the process are replaced by those of the new program."*

Pretty slick.  I guess that's what was happening under the surface every time I've exec'ed anything at all, but I didn't totally grasp the significance, or how I could use it to be amazing.
		
And that's it.  Of course, the new invocation will go through the update cycle all over again, but this time the latest version's checksum will match the checksum of the binary on disk, and the tool will proceed.

Q.E.D.


## Reference Implementation

The above concepts, implemented: [DBT Dynamic Binary Toolkit](https://github.com/nikogura/dbt)
