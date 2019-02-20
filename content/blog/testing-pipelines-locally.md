---
title: "Testing CI Pipelines Locally"
tags: ["DevOps", "OSS"]
date: 2019-02-08T10:39:00-04:00
draft: false
---

Usually, continuous integration (CI) setups are portable and reliable.
That is, tests that pass locally will pass in the same way on a CI service, but if that were always the case, there wouldn't be a need for remote servers!
The purpose of a continuous integration service is [outside the scope of this article]({{< ref "blog/too-much-ci.md" >}}), since I'd like to show how to duplicate a test environment locally to debug an issue that doesn't appear when running the tests in your development environment.

[Docker](https://www.docker.com/) is a popular containerization tool; it allows you to construct an "image", which is akin to an entire operating system installation independent (for most purposes) from your existing operating system and software.
That is, you could be running a Debian linux image on Centos, OSX, or Windows; moreover, as long as you're using executables available inside the image, the results of a process you run should be the same on each of those platforms (again, for most purposes).
This makes Docker a good solution for isolating your test environment from system upgrades and other situations that can foul up your development environment.
Docker is not without downsides, however: to some extent, you are trading this flexibility with your disk space and some performance overhead, among other things, and the requirement of learning a new tool can be considerable.

Here I'm going to describe the process I went through to debug and streamline [this repository](https://bitbucket.org/jgoldfar/ndce-python), which requires Python + NumPy for the numerical part, as well as LaTeX for the documentation.
I find that it's best to combine an expressive programming language + inline comments and a robust document preparation system for expository and explanatory writing in this way.


I'll start this image using [my minimal Debian Linux-based LaTeX image](https://cloud.docker.com/repository/docker/jgoldfar/latex-docker); the command below runs `ls /data` in this image, where the current working directory is mounted inside the container as `/data/`:

```shell
docker run -it -v $(pwd):/data jgoldfar/latex-docker:debian-minimal-latest ls /data
```

The smaller images lend themselves to faster startup and execution, as well as better isolation of your processes from additional packages that are installed in other distributions.
After looking at [how I might install Conda]({{< ref "blog/installing-jupyter-with-R-and-julia.md" >}}) Conda in a docker image (which [I use separately](https://cloud.docker.com/u/jgoldfar/repository/docker/jgoldfar/miniconda3), of course), I decided to make [a new image](https://cloud.docker.com/u/jgoldfar/repository/docker/jgoldfar/miniconda3-latex) containing both Conda and the minimal LaTeX installation to bring down CI times: building the images is a one-time cost.

Each build, however, will necessarily include package installation for a given project, instead of relying on them being present in the environment.
This allows your CI configuration to document most of the dependencies for your project, but is a cost you'll pay each time.

Disk space is also not free, but nevertheless, I prefer to use Miniconda environments to further isolate python projects when working locally, and while this isn't necessary in a docker container, I'll test that it works in that setting.

But this requires that several commands be run in your docker environment, and since multi-line commands need to be entered in a non-intuitive way anyways, I think it makes sense to put most of the installation/setup steps in a script or Makefile in your repository.

For instance, you can put

```makefile
SHELL=/bin/bash

make-conda-env:
  conda create -y --name ndce-python python=3
  source activate ndce-python && \
  pip install -r requirements.txt
```

in the makefile in the root of your repository, and run

```shell
docker run -it -v $(pwd):/data --workdir /data jgoldfar/miniconda3-latex:minimal make conda-env
```

to run those commands in your container.
This command runs `make conda-env` in my [`miniconda3-latex:minimal`]() image with the pwd set to `/data`, which is mapped to your current user's pwd.

Note that I've set an explicit shell in the makefile, since the default shell even in a Debian environment doesn't seem to work well with the way the Miniconda installer sets things up.
Once this is working for you, iterate on the test script (adding more targets if necessary) to get things working.
Sometimes it makes sense to separate expensive and slowly-changing requirements into the image build phase and quicker build steps into the CI configuration, which can obfuscate the overall installation process and dependency list slightly, but can lead to overall smaller CI times.
Deciding what instructions to put where would be an interesting optimization problem!

*Note*: If you're in need of a "quick fix" instead of a solution that can be tracked in a VCS, you can run multi-line scripts by passing them to `sh`:

```shell
docker run --interactive -v $(pwd):/home --workdir /home --tty jgoldfar/latex-docker:alpine-minimal-latest sh -c "ls -l && make test"
```

## Future Work

* Build Miniconda3 from source on Alpine to further reduce the image size.

* In the past, I've used tools Travis CI has made open source to approximate their build environment; documenting how to do this would be useful (otherwise I'll have to figure this out again).

* Same with CircleCI
