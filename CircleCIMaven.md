## Using CircleCI as if it was a Maven Repo

This little gem is from the 1.x version of CircleCI.  They already did the hard part of making the artifacts available online.  They need to take the next step and provide the web path tree that Maven expects, and then their builds are all automagically Maven repos too.

Until then, here's how I made it work:

    dependencies:
      pre:
        - wget $(curl -s "https://circleci.com/api/v1.1/project/github/nikogura/homebrew-formula-plugin/latest/artifacts?branch=master&filter=successful" | grep '"url"' | cut -d' ' -f5 | sed 's/[",]//g' | sed 's/^ *//')
        - mvn install:install-file -Dfile=homebrew-formula-plugin-1.0.0-RELEASE.jar -DgroupId=com.nikogura -DartifactId=homebrew-formula-plugin -Dversion=1.0.0-RELEASE

Basically it finds the dependency artifact, and loads it into the local container's maven cache, and then bob's yer uncle.

Here's an example in use:

[https://github.com/nikogura/boxpile/blob/master/circle.yml](https://github.com/nikogura/boxpile/blob/master/circle.yml)
