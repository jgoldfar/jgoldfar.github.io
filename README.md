## Personal Website Generator for Jonathan Goldfarb ##

* v2018.1

### Usage ##

First, clone the website generator into the correct path; to install all of the remotely generated sources, run

    make pull-deps

To initialize the git repository we use to track and upload the website, run

    make init-git

Generate the files and push them to the remote by running

    make push-git

To make more significant changes to the pages, it is recommended to run `hugo` as a server, using

    make serve