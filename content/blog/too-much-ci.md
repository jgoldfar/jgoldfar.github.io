---
title: "Continuous Integration Ad Nauseam?"
tags: ["CI"]
draft: false
date: 2018-09-18
---

Anyone who's tried to look back on a document from years ago probably knows how difficult it can be for anything more than the simplest files.
There are [good](https://en.wikipedia.org/wiki/Software_rot) [reasons](https://en.wikipedia.org/wiki/Entropy) why, over a long enough time scale, such problems are likely unavoidable (though that [doesn't](https://en.wikipedia.org/wiki/Voyager_Golden_Record) [stop](https://en.wikipedia.org/wiki/Long_Now_Foundation) us from [trying](http://www.slate.com/articles/health_and_science/green_room/2009/11/atomic_priesthoods_thorn_landscapes_and_munchian_pictograms.html), with completely unknown results.)

A backup is no good if you can't open it, and even if it opens or runs on your machine, how do you know the recipient of your work has a chance of having the same luck.
Not to mention the possibility that an inevitable computer crash or upgrade could have disastrous consequences for the future of your work.
Speaking for myself, as the recipient of multiple literal crashes (with cars, on my bike) and regular deluges during my commute, it's a wonder my 2012 MacBook still runs.
Indeed, some days it refuses to.

I'm going to give my solution for the short-term problem of being able to reliably open and run _your own_ work for about as long as you care to keep it around.
Long story short, I've developed some techniques for running all kinds of codes on multiple CI services, as well as my own package for checking that my "mono-repo" correctly integrates changes and can continue to compile, well, everything I've worked on dating back to 2005 or so (I am lucky to be an early TeX and OSS adopter for my own work, so I'm not stuck with many opaque binary files; that would be a significant limitation...)

The base repository wasn't designed to be open source from the outset, so it contains possibly sensitive work information (ah, isn't it nice to know that nothing you commit, even by accident, can be lost...)[1]
While I can't share that, I can show how my CI system works.

## Requirements

1) The whole thing should be as automated as possible, and work natively with my version control system.
No existing CI service I could find supports private repositories and the rather idiosyncratic range of dependencies the wide range of projects I've worked on.
The CI system I created here uses a system of lockfiles and exercises `cron` to ensure that updates to the global state of the base repository are pulled to a local directory regularly, each pulled commit is only built once, and the repository/build is never put into an inconsistent state by pulling during a build or vice-versa.
I thought about leveraging a kind of state machine here, but the transitions are few and simple enough that the current system works.

2) Aside from some minimal configuration information, the system should not require a significant test apparatus to be added to existing repositories.
Some of these repositories are shared with other users, who would find a heavy added dependency a bother, at the very least, and after implementing this system, I don't want to do significant amounts of additional work just to get tests running in each repository.
Indeed, after the initial implementation, I was able to add more specific tests incrementally while retaining a measure of how well existing codes met a minimal standard.

3) In particular, existing tests should be discovered automatically and run in as natural a way as possible.
Since I'm a Linux and OSX user, `make` tends to be my automation and build tool of choice; I decided that by default I should just check the output of `make check`, and put any linting or other test automation there.
One of my goals was to ensure that "root" TeX files (not the include files, of course) can continue to be compiled against all of the other (possibly external to the current repository, for highly modular documents) files contained in the repository; rather than reinvent the wheel here, I opted to use `latexmk -pdf` to compile _every_ TeX file in the repository.
The list of TeX files to compile or skip is configurable on a per-directory basis, which turns out to be lightweight enough for my use-case.

4) The output should be uploaded to support formation reports related to the overall health of the repository.
More on this later; since I generate logfiles in a somewhat standard format, I found it easiest to just build tools that parse the output logs and form summary information based on that output.

## Some Details

Take a look [here](http://bitbucket.org/jgoldfar/cmstest.jl) for what I've come up with as an implementation of this idea; basically, on a regular basis, commits are pulled from the base repository to a local directory.
In order for this to complete in a reasonable amount of time, they are pulled and force-updated over an existing clone; this is unfortunate, since some state from the previous pull may remain.
It would be interesting in the future to grow a family of local repositories and regularly re-clone old ones while using a new one in a round-robin style.

Separately, by querying the local repository, the latest commit hash is discovered; by comparing this to the expected output location, we can determine if tests need to be run, and if so, we do.

Running tests works recursively, and runs a few different things: first, we read in a configuration file to customize (if necessary) the files to be checked, scripts to be run to build PDF files, etc.
Then

1) Check if OSS equivalent codes exist for each code that is determined to have a closed-source-only extension.
It would be good to actually check the output is the same, but that's the crux of the problem, isn't it...

2) Check that each repository has a README and LICENSE.
This seems (to me) to be the bare minimum of documentation and information one would need to return to a project years later and know at all what's going on.

3) Check that TeX files compile.
By default, `latexmk` is used, but it's nearly trivial to use `make`.
Creating blacklists or whitelists of files to skip or compile, respectively, isn't too tricky either.

4) Run the repository's `make check` command, or any other command configured for the repository in the configuration file.

Based on tracing the execution of the script and some basic estimation, it seems as though the current implementation adds as little overhead as possible on top of the huge amount of compilation and other tests that have to be run.

The reports are generated into directories outside the base repository tree.
Once a sentinel value is found in the log file, uniquely showing that the build has ended, another script picks up from there:

1) Parse the logfile and create a nice summary Markdown file

2) Parse the previous commit logfile and create a list of new failures, tests, etc.

3) Create a test trend image using gnuplot, and

4) Commit all of the files corresponding to the given build to a git repository and push these changes.

## Future work

* If some dependency analysis could be added, tests could be run in parallel. This is (likely) much trickier than just running the tests asynchronously.

* Move more dependencies into the CMSTest repository (particularly, the log parsing logic,) rather than having those files live in the reporting repository and potentially fall out of sync with the CMSTest package.

* Add tests to this system (WIP)

## Footnotes

[1] While I know it's well possible to scrub data from commits, I don't think it's worth the effort.