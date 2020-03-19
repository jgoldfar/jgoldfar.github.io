---
title: "Building Zeal"
date: 2019-01-25T11:06:51
tags: ["OSS"]
draft: true
---

## Motivation

Since I do quite a bit of work remotely (or at least offline) and still lack a photographic memory, having documentation offline is pretty useful; I've used [Zeal](https://github.com/zealdocs/zeal) for a while on my Linux machine, but would really like to use it everywhere...
But building Zeal on OSX is not trivial.

The primary issue is that it depends on a Qt5 component, the Webkit interface, that has apparently been on the way out for a while.
Luckily, everything we need is open source, and (given enough time) we can build just about anything (right?)

## Building QtWebkit

As you can see [here](https://travis-ci.org/jgoldfar/qtwebkit), my attempts to get Travis to build QtWebkit for me were not successful.
I was mainly focussed on getting OSX up-and-running, which it would, if we could speed up the build at all; determining the correct prerequisite packages to install on a Linux platform is all that should be required to allow them to time-out as well...
The resulting library and include files (built using Clang on OSX 10.12.6, using the same configuration as on CI, followed by `ninja install` in the build directory) are available [on Bintray here](https://bintray.com/jgoldfar/BlogPostSources/download_file?file_path=qtwebkit-4ad2c91b6d7a6d67e48f6b0252b33eb1d3a00135.x86_64-darwin.tar.gz).
These work locally after "pasting" them somewhere accessible by the `Zeal` build system on your local machine and pointing it that direction, but this is not currently reproducible on CI.

## Building Zeal

As expected, [Travis refused](https://travis-ci.org/jgoldfar/zeal) to build Zeal on OSX, but if you've asked `brew` to install the necessary dependencies and follow the same [script](https://github.com/jgoldfar/zeal/blob/enable-travis/.travis.yml) (changing any necessary paths) you should be able to build Zeal correctly.
So far, I've not run into any issues with the slightly mismatched versions of Qt being used at various stages of the build, but compiling everything against the same versions of the dependent packages would lead to a more reliable product.

## Future Work

* Generate QtWebkit matching exactly with installed versions and use precompiled libraries and headers.
