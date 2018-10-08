## Personal Website Generator for Jonathan Goldfarb ##

* v2018.1

Generated using [Hugo v0.40.3](http://gohugo.io/).

Currently the build requires a Unix-like platform, and `make`, `curl`, `rsync`, and `git`.
`rsync` can be avoided by setting the option `RSYNC=cp` after your make invocation, as is
done on the CI platform Bitbucket Pipelines.
Rsync is just used to reduce the overhead of generating and moving multiple files over an
existing built site.

### Usage ##

First, clone the website generator into the correct path; to install all of the remotely generated sources, run

    make pull-deps
    
`pull-deps` currently brings in the following source material:

* [Algebra Reading Group Notes](https://bitbucket.org/jgoldfar/algebrareadinggroupnotes)

* [Resume and CV files](https://bitbucket.org/jgoldfar/resumepublic)

In the future, it is planned that the schedule file will also be generated automatically,
along with other files related to e.g. OSS repositories.

To initialize the git repository we use to track and upload the website, run

    make init-git

Generate the files and push them to the remote by running

    make push-git

`push-git` runs `init-git` (documented above) as well as `gen-git`, which generates the 
HTML files into the correct location. The commands under the `push-git` target take care of
just the commit & push steps.

As documented in the CI file `bitbucket-pipelines.yml`, the recommended sequence of steps
to generate and push an update are

    make pull-deps push-git

### Other Useful Commands ###

To make more significant changes to the pages, it is recommended to run `hugo` as a server, using

    make serve

To generate a new page (in particular, to automatically set the date) run

    make new FileName=...

In particular, to make a new blog post with the title (for instance) `ImplicitFunctionTheoremApplications`, run

    make new FileName=blog/ImplicitFunctionTheoremApplications