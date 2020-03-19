---
title: "Hosting Binaries on Bintray"
tags: ["DevOps"]
date: 2018-11-30T08:57:59
draft: false
---

As a part of my never-ending quest to make my research materials highly available (in the [system uptime](https://en.wikipedia.org/wiki/High_availability), or reproducibility sense of the phrase), I do my best to make sure that the data and other portions of my work that can be made open are hosted on publicly available servers, preferably behind a [CDN](https://en.wikipedia.org/wiki/Content_delivery_network).

Backups and version control avoid a good portion of the single-point-of-failure issue, and with a bit more effort (luckily, only a one-time cost, too!) one can avoid vendor lockin for your content distribution by relying on [open source tools]({{< ref "/posts/why-oss.md" >}}) as much as possible.
While the jury is still out on my level of sanity, particularly when it comes to these sorts of issues, I can confidently say that the number of times a colleague, student, or (more often) a portion of a data-processing pipeline I've set up has come up short when it comes to accessing my data has dropped significantly since I've invested in learning how to set things up this way.

[Bintray](https://bintray.com/) is a popular host for versioned software binaries; I've used it in the past to host test-only data dependencies, for instance, and you would probably find that it provides the actual data behind the download links for much of your favorite software.
However, the ease with which it can be used in an automated fashion makes it ideal for archiving versions of documents and other research artifacts, particularly when the generation of those artifacts is closed source or otherwise cannot be shared.
I've recently started using Bintray to host public data related to my CV and the slides for presentations I've given; I think it makes sense to archive things like datasets that are expensive to recompute, or data visualizations in the same way.

In this post, I'll share how to set up a repository on Bintray for this purpose and integrate it into your build process.
You'll notice that (as one might expect from its "intended" purpose) some of the terminology needs some translation for our purposes, and we won't be using all of the features of the service.


## Steps to Upload and Publish Files

Bintray organizes files under your user account into "repositories", which are just collections of (hopefully related) packages, which are themselves collections of files.
After making your account, creating a new repository is as simple as clicking "Add New Repository".
I'm only interested in public file hosting (private hosting requires a paid account anyways) so go ahead and choose that option, as well as a name.
Under the "Type" drop-down box, select "Generic".

I'll demonstrate how to upload files from the command line using my "all-talk-slides" repository as an example.
You'll need to create a package within your repository using the "Add New" button and provide a name, license, and link to your version control repository for your files.
[Choosing a license](https://choosealicense.com/) can be tricky; generally, anything you post online is assumed to have your copyright (please, keep in mind I'm not a lawyer!) but Bintray requires that you explicitly specify in what way you are making your files available.

Once you have a package, you'll need to tag a version to upload to.
I'll use my `slide-binaries` package as an example.
If you're uploading a "finished product" it probably makes sense to create a version 1.0, but one can imagine work-in-progress scenarios where another system of versioning your files makes sense.

Having all of this, check your Bintray `API_KEY`; this is accessible by clicking your name in the Bintray UI, selecting "Edit Profile", and clicking to "API Key".
Either save this value in a variable locally, or make it available in your (e.g. CI) environment.

The UI also provides directions to upload your files via `cURL`; when I automate this step, I typically use the direct upload method (if there's some advantage to another method, let me know in the comments!)
You'll have to make the obvious changes to specify your username, repository, package, and version; it's easiest to store these in environment variables or your `Makefile` as well:

```
export BT_REPO=all-talk-slides
export BT_PACKAGE=slide-binaries
export BT_VERSION=1.0
export BT_USERNAME=jgoldfar
export BT_API_KEY=...
curl -T <path/to/FILE.EXT> -u${BT_USERNAME}:${BT_API_KEY} https://api.bintray.com/content/${BT_USERNAME}/${BT_REPO}/${BT_PACKAGE}/${BT_VERSION}/<FILE_TARGET_PATH>
```

You can upload as many files as you would like this way, using the above command repeatedly.
Once you're ready to make those files available, the whole package and version needs to be published, which you can do by running

```
curl -X POST -u${BT_USERNAME}:${BT_API_KEY} https://api.bintray.com/content/${BT_USERNAME}/${BT_REPO}/${BT_PACKAGE}/${BT_VERSION}/publish
```

Using `cURL` and Bintray's REST API this way makes the whole process nearly pain-free; all of the packages and repositories you see on [my Bintray page](https://bintray.com/jgoldfar) are generated automatically as part of build processes on private services using these steps.

## Future Work

* Bintray offers a lot of features, including analytics, that can be run on your files, packages, repos, etc. that would be interesting to explore at some point.
