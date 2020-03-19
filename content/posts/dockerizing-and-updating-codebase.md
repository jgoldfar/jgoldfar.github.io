---
title: "Containerizing and (Eventually) Updating pdf2htmlEX"
tags: ["OSS", "DevOps", "Docker"]
draft: true
date: 2018-10-10
---

We've all been there: you're asked to solve a technical problem ("compiling" a TeX file to the web with minimal changes to the content) and someone has done [an impressive job](http://coolwanglu.github.io/pdf2htmlEX/doc/tb108wang.pdf) towards solving this problem, just a few short years ago.
And, the project, pdf2htmlEX, [is open source!](https://github.com/coolwanglu/pdf2htmlEX)
But as happens with projects that fill a particular niche, this particular project is unmaintained by the original author.
Some kind contributors seem to have [picked up](https://github.com/pdf2htmlEX/pdf2htmlEX) where the original author left off, but this project, too has languished.
pdf2htmlEX doesn't build on any "modern" system using "off the shelf" components.
In fact, there are existing issues (including [this one](https://github.com/pdf2htmlEX/pdf2htmlEX/issues/15) on various repositories related to fixing this issue, as well as a build script that one of the new maintainers posted that claims to build successfully on one platform.

If we're going to adopt this as a solution to our problem, clearly there's a bit of work to be done.

## Step 1: Containerization

The most obvious first step is to get some version of pdf2htmlEX to build against some combination of dependencies; [docker](https://www.docker.com/) is an obvious choice here, since it offers the killer combination of portability and containerization: using a docker image, though large on disk space, will completely encapsulate the build dependencies from other software on a given system and offer a kind of reproducibility to the use of pdf2htmlEX as it stands now.

In order to make later experimentation a bit quicker, I separated the Docker images into three parts:

1) [Base](https://hub.docker.com/r/jgoldfar/pdf2htmlex-base/), containing a debian-based image with the system packages necessary to build the dependencies of pdf2htmlEX and the package itself.

2) [Deps](https://hub.docker.com/r/jgoldfar/pdf2htmlex-deps/), building off of Base to provide source-build installations of known-good versions of the key dependencies for pdf2htmlEX.

3) [Stable](https://hub.docker.com/r/jgoldfar/pdf2htmlex-stable/), building off Deps, which just contains the master version of pdf2htmlEX, pulled from the git repo and compiled from source against the previous images.

## Step 2: Automation

Once the docker images build locally, it's a simple process to create a Travis-CI file to automate the creation and uploading of those images to Docker Hub.
Travis needs to be given your Docker username and password as environment variables, which it will helpfully keep secret for you.
I have set up Travis to automatically build new images on a monthly basis, unless another build as happened recently; you can see the build [here](https://travis-ci.org/jgoldfar/pdf2htmlEX-docker), which uses Dockerfiles from [this repository](https://github.com/jgoldfar/pdf2htmlEX-docker)

## Step 3: Reporting

Once a version of the package is known to build, CI should be able to build the package using nearly the same script as is found in the Dockerfile.
At the very least, Travis should be switched on, so we know how far we are from success; this has been completed in [this PR](https://github.com/pdf2htmlEX/pdf2htmlEX/pull/16) on top of some work by Rockstar04 and now merged into.
A little bit more work on [a separate branch](https://github.com/jgoldfar/pdf2htmlEX/tree/fix-travis-linux), including some fiddling with the build, has finally allowed the compilation to complete, and many of the automated tests can now be switched back on.

## Future Work

* Separating the docker build into separate stages was intended to make it easier to upgrade poppler and fontforge, among the other dependencies, until they are even with the versions available from system package managers.
This updating process should now proceed.

* A more minimal version of the dockerfile would be better: can this be build on top of the Alpine or minideb base images?

* Turn on compilation & tests for OSX platform as well. This is actually enabled currently in the CI configuration, but is allowed to fail: apparently [an outstanding issue](https://github.com/fontforge/fontforge/issues/3077) with fontforge blocks this effort.

* Upstream build process to homebrew (would be a new challenge!)
