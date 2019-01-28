---
title: "Colophon"
date: 2018-11-10T16:45:18
tags: [""]
draft: false
---

This page is generated using [Hugo](https://gohugo.io/) from a repository [here](https://bitbucket.org/jgoldfar/personal-site/).

The font is [Raleway](https://fonts.google.com/specimen/Raleway), and we use [PureCSS](https://purecss.io/) and [FontAwesome](https://fontawesome.com/?from=io).

The theme is based on an old site layout I had used, but I'm [growing a bit tired of it.](https://cloud.docker.com/u/jgoldfar/repository/docker/jgoldfar/latex-julia-docker)
You'd probably guess that I don't have much design in my background, despite an appreciation for good aesthetics.

In particular, Bitbuckets CI automatically builds the site in [this Docker image](
https://cloud.docker.com/u/jgoldfar/repository/docker/jgoldfar/latex-julia-docker), which includes some additional tools that we use to generate some files.

* The listing of open source projects is generated automatically using the Github and Bitbucket APIs

* My CV and list of publications are generated automatically in their own repository, posted to Bintray in BibTeX format, converted using a script in my [bibserver fork](https://github.com/jgoldfar/bibserver/tree/jgoldfar-bibtexparser-23-support), and formatted using a [Hugo data template](https://gohugo.io/templates/data-templates/).

This is all automated using a Makefile you can find [here](https://bitbucket.org/jgoldfar/personal-site/src/default/Makefile).
