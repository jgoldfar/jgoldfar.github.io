## Personal Website Generator for Jonathan Goldfarb ##

* v2018.1

### Usage ##

Since the generation is currently handled at least partially on a machine with access to other files related to my personal website, the existence of some of these files is currently required to completely generate the website.

First, clone the website generator into the correct path; to install all of the publicly available sources, run

    make pull-deps

Either place `cv.pdf` and `res.pdf` into `static/cv`, or run

    make update-cv

if you have the resume repository in the correct location.

To initialize the git repository we use to track and upload the website, run

    make init-git

Generate the files and push them to the remote by running

    make push-git

To make more significant changes to the pages, it is recommended to run `hugo` as a server, using

    make serve