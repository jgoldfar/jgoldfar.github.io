---
title: "One more round with Hyde"
tags: ["OSS", "DevOps", "WebDev"]
draft: false
---

Let's say you've got a legacy website built with an unmaintained static website generator, but a new change comes around requiring a minor update.
What to do?
Clearly, there are at least two options:

1) Choose a new static website generator that supports all of the bells and whistles of your old one, convert all of the old content to the new template language, and keep tweaking the configuration, themes, etc. until the output is just right.
That's what I did with this website some time back, and it was quite a bit more time consuming than I'd care to admit; the results are hosted in the corresponding public repository [here](https://bitbucket.org/jgoldfar/personal-site), and perhaps I'll write about the experience some day.
Suffice it to say that, despite the relatively friendly initial experience, as a non Gopher, it is clear that configuring Hugo to do what I want will take a while.

or,

2) Pick up the old, unmaintained static website generator ([Yay for FOSS!]({{< ref "blog/why-oss.md" >}})), make it work in a reproducible way, and package it up so you won't have to bother with the technical side of this problem again (one hopes)

Given that the old static website generator, [Hyde](http://hyde.github.io/) (Github repository [here](https://github.com/hyde/hyde)) was written in Python 2, with some steps towards Python 3 support, obviously the latter was a more attractive solution.
It gave me an opportunity to play around with some sides of Python I haven't messed with in a while, as well as tools like [pipenv](https://pipenv.readthedocs.io/en/latest/) (which I'm going to be using as much as I can! Very friendly!) and [tox](https://pypi.org/project/tox/).

## Patching up Hyde

Hyde hasn't had a commit to its main repository for almost 3 years now; while this isn't disqualifying for a project that could be considered mature written in Python 2 (which also isn't going anywhere soon) I found that I couldn't load the script on my machine, and though PRs hadn't been accepted since 2016, all of the recent ones failed CI, so something is amiss.
I'm a [big fan](< ref "blog/too-much-ci.md" >) of continuous integration, in particular on [Travis CI](https://travis-ci.org/) and make active use of Travis' Cron jobs to keep tabs on whether I can reliably come back to a previous project and expect it to work, at least in some capacity.

So, first things first, I cloned the Hyde repository and ran the tests according to the CI configuration.
No go (as expected.)
That is, the tests themselves didn't run.
Flipping the switch on the repo's corresponding Travis page unsurprisingly gave a failure as well.
But, the package itself did load when built from the `master` branch, so there wouldn't need to be _too_ much poking around in the main package codebase, at least to get the tests passing.
There are some bits that are interesting to think about and read, though, such as the plugin and backend management system; Python makes those kinds of things relatively ergonomic, even with conditional dependencies.
Since the original test framework `nose` is in maintenance mode, I figured it would be a good time to play around with [`nose2`](https://github.com/nose-devs/nose2), which would better support a Python 2 + 3 package.

As promised, some features from `nose` that were heavily used in the Hyde tests were not yet implemented in `nose2`; in particular, the `@raise` decorator, and `@with_setup`/`@with_teardown` don't yet work with class-based tests.
Though it's obviously sub-optimal, it was trivial to "inline" the action of those decorators into the tests.
One test dependency of Hyde, asciidoc, just wouldn't run on my machine in the couple hours I had given myself for this project, so I disabled the corresponding test while getting the test scripts running; a couple other tests for the output of Javascript dependencies were documented to be fragile , and will need to be updated (and is it within scope of the site generator to check that external projects like `uglifyjs` behave? Maybe?)
A couple of the plugin tests don't behave anymore either, which would require a bit more digging.

While I was at it, I figured it would make sense to use a `npm` `package.json` script to track the Javascript dependencies, rather than hard-coding those in the CI file.
`npm` helpfully nags you if the versions of your dependent packages have security issues, which the pinned versions did. `npm audit` is a neat tool!

Hyde also tests for PEP8 conformity using `flake8`, which is nice, but the package had fallen behind the times; those issues were quite easy to fix.
Lastly, the documentation build needed some tweaks.

According to my commit history, the whole process took a couple of hours of work; the branch with the current state of things, such as they are, is [here](https://github.com/jgoldfar/hyde/commits/fixes-for-python27).
I wouldn't say it's fixed (given a test coverage sitting at 61%, it very well might fail in unfortunate and surprising ways...), but it's at least reproducibly in its current state, and it works for my purposes!


## Future-proofing the whole deal

That still leaves the question of generating these changes, and making sure that I wouldn't have to bother with this nonsense again.
It's all well and good to have a working dependency today, but there's not much chance Hyde will be resurrected and become active (or even reach version 1.0) ever.
Moreover, when I used it in the past and it _was_ being maintained more actively, Hyde would have perennial conflicts with other tools I had installed over dependency resolution.
This is where `pipenv` comes in; simply running

```
pipenv --two install -e git+https://github.com/jgoldfar/hyde.git@fixes-for-python2.7#egg=hyde
```

in the website directory was enough to grab my updated Hyde source tree, along with its dependencies, and make it all available only to this project (if necessary) with a Python 2 virtual environment.
This also created a nice `Pipfile` that records the Python version and package dependencies, so simply running

```
pipenv install
```

would be enough next time.
Once Hyde was up-and-running in this environment, I could make my template changes as necessary, and regenerate the output like I did long ago.
Nostalgia!

Is that enough?
Of course not!
My laptop is far from rock solid machine, as I've written, which is part of [my reason](< ref "blog/too-much-ci.md" >) for assiduously setting up continuous integration for as much as I can.
The website code was already up on Bitbucket, and they've just started offering their very nice [Pipelines](https://confluence.atlassian.com/bitbucket/build-test-and-deploy-with-pipelines-792496469.html) service, which allows you to run a test script using any docker image you'd like.
The top [existing `pipenv` image](https://hub.docker.com/r/kennethreitz/pipenv/) didn't seem to support Python2, but it was relatively simple to [fork](https://github.com/jgoldfar/circleci-pipenv) a Dockerfile and set up an automated build on docker hub for [my own image](https://hub.docker.com/r/jgoldfar/circleci-pipenv/).

With this docker image in hand, and a bit of automation hidden away in a simple `Makefile`, simply creating a `bitbucket-pipelines.yml` file with the contents

```
image: jgoldfar/circleci-pipenv:latest

pipelines:
  default:
    - step:
        script:
          - make generate
```

will automatically complete the previous couple steps within that docker image and check that the package generation completes successfully.

I then added a packaging step to the `Makefile` so I can easily send the generated HTML files upstream, and the [Bitbucket API](https://developer.atlassian.com/bitbucket/api/2/reference/) allows authorized apps to upload files to repositories to be made available as downloads, so I can just go there any time I'd like access to those files.

The finished product, as it were, is in the repository [here](https://bitbucket.org/jgoldfar/drabdullasitegenerator/).
I take no ownership of the content of the website itself; there I was just transcribing what I was told to add, and I certainly don't claim responsibility for the color choices, but the templates and configuration are my work.
If I had to do it all over again, I probably wouldn't, but at least the technical part was interesting!

## TODOs

* Document the process for getting the necessary dependencies and running tests locally in `test/README.rst`

* Update the expected output, or (even better) robustify the tests for external tools

* Run tests on OSX to catch possible future build errors like the one I originally ran into.

* Add some regression checks for the output of this particular website.