---
title: "Reviving an ancient MacBook"
date: 2018-10-20T20:44:16
tags: [""]
draft: false
---

Well, it finally happened: my ancient (by modern, consumerist standards) macbook finally kicked the bucket.
The fact that a 6 year old laptop is on death's door is a sad statement about the reliability and repairability of the technology we rely on, and it's by no means unique to Apple products, since I've had similarly flaky Dell and Acer machines.

I've been expecting this for a while, of course, hence my obsession with backups and [continuous integration]({{ ref "blog/too-much-ci.md" }}), which offers some kind of guarantee that moving to another machine won't break everything I'm working on.

That said, there's never a good time to lose use of a tool.
Luckily, I have another, even older tool to dig up!
That's right, I've had a unibody MacBook sitting at the back of a shelf for quite some time.
I originally stopped using this machine because the battery started swelling up in an alarming way, but luckily, this happened back when batteries could be removed, so it's perfectly usable as long as you don't move it.
It runs OSX 10.6.8, and doesn't seem to be in the mood to update anything anymore.
This presents a significant issue, since just about 0% of the software I take for granted will work "out of the box" on such an old platform; though this is purely a personal journey (preserved here in case this is useful to anyone else ever), I find it instructive to think about how many people in the world are caught between the "supported" platforms, and those they can afford or understand.
It's astounding how much of the web is simply unavailable, or will not display correctly, to the long tail of users on Safari 5, which I now count myself among.
The README and INSTALL files for widespread utilities can't cover every eventuality, of course, but there is practically no documentation of known-good configurations, dependencies, etc. independent of the context the software was originally found.
Many, if not all, of the software that I write is guilty of this same issue: it works well against my system, and is tested to work in some capacity guaranteed by whatever tests I can think to write against a few others.
But that doesn't really give the whole story, when it comes to how that software works.
It brings to mind the classic apple pie recipe, which could be shoehorned into something like "in order to run this software, you must first create the universe."

## Goals

Now, I know this will never again be a computational powerhouse, but these days there's easy and cheap enough access to other people's servers that I probably won't have such a machine as a daily driver anyways.
A glorified PDF reader and typewriter/code terminal will serve 90% of my needs, which are

* SSH needs to work
* Mercurial
* Git
* TeXLive
* Anything else I can get running

The fifth point there is really more of a curiousity; spending too much time there would certainly be a waste, particularly considering what a timesink this has already been.
But, good news: I'm typing this right now on my revived MacBook!

## Getting SSH working
The available version of Safari is so old that practically no websites will load, since SSL/TLS won't allow it (in particular, [Homebrew's site](brew.sh) won't load.)
However, since Bitbucket somewhat-works on Safari, navigating directly to my account settings allowed clicking to the SSH key settings page, after which following [the standard directions](https://confluence.atlassian.com/bitbucket/set-up-an-ssh-key-728138079.html) worked just fine.
To make sure your SSH identity continues to work after the current session, add a line like

```
Host *
 IdentityFile /path/to/id_bitbucket
```

to `~/.ssh/config`.
You can check that things are working, as suggested in the above documentation, by running

```
ssh -T git@bitbucket.org
```

## Getting Mercurial working
Now that SSH is running, it makes sense to check if Mercurial will work.
We're in luck!
The [Mercurial website](mercurial-scm.org/) also allows super old secure connections, so we can just navigate there; of course, Mercurial dropped support for Python 2.6 way back [in version 4.2.3](https://www.mercurial-scm.org/wiki/SupportedPythonVersions), but [the available installer](https://www.mercurial-scm.org/downloads) "just works" (I went even older to a 3.x release.)

Having that, I've been able to clone my CMS without any issue (modulo directories that have been replaced by subrepositores, of course)

## Getting Homebrew Back in Business
The most obvious way to bootstrap this system back into usability was to install all of the necessary tools through Homebrew.
However, the available version of Safari is so old that practically no websites will load, since SSL/TLS won't allow it (in particular, [Homebrew's site](brew.sh) won't load.)
By the same token, the available Curl installation is too old to allow installing Homebrew, even if we could get to the site (thanks, `curl | sh` installation! Not that I have a better, more ergonomic option.)
We could go ahead and build Curl, but of course [its website](https://curl.haxx.se/) won't allow us to connect; can we clone [the repository](https://github.com/curl/curl)? of course not! `git` isn't available; we would apparently need a version as far back as v1.6, which [isn't available](https://mirrors.edge.kernel.org/pub/software/scm/git/); all of the versions I tried ran into linking issues, leaving us the option of a binary distribution.
I've used [SmartGit](https://www.syntevo.com/smartgit/) in the past, and they have a version still available that will install and run on this machine, and includes its own git installation, so that's what I went with.

Now that `git` is available, we can clone `curl`'s repository and work on building that:

## Detour: building `cURL`

One of these days if I'm bored enough, I'll go through these directions on a clean install.
That would have to be pretty severe...
But anyways, I had autotools already available, so that was nice.
The git repository doesn't come with much, so I first had to run

```
autoreconf --install
```

to make sure all of the `m4` macros we could make available would be, but `cURL` still expects a slightly newer autotools installation, apparently.
I had to apply the patch below:

```
diff --git a/configure.ac b/configure.ac
index 82ff503..dd7912c 100755
--- a/configure.ac
+++ b/configure.ac
@@ -39,7 +39,8 @@ AC_CONFIG_SRCDIR([lib/urldata.h])
 AC_CONFIG_HEADERS(lib/curl_config.h)
 AC_CONFIG_MACRO_DIR([m4])
 AM_MAINTAINER_MODE
-m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])
+m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])],
+         [AC_SUBST([AM_DEFAULT_VERBOSITY], [1])])
 
 CURL_CHECK_OPTION_DEBUG
 CURL_CHECK_OPTION_OPTIMIZE
```

to set `AM_DEFAULT_VERBOSITY`, after which 

```
./buildconf
./configure
make
sudo make install
```

worked just fine.

Of course, this wasn't quite enough: a newer SSL library had to be installed along with cURL; I went with [MbedTLS](https://tls.mbed.org/), which is used by other projects I'm involved in.
I figured the minimiality of the package might help it successfully compile, and it did: after downloading the source, patch the Makefile under `library/` to fix a ranlib option according to
```
50c50
< RLFLAGS = -no_warning_for_no_symbols -c
---
> RLFLAGS = -c
```

and disable the tests by patching the main Makefile as

```
21d20
<	$(MAKE) -C tests
```

before running

```
make
sudo make install
```

Then, back in the `cURL` install directory, re-run the last three steps to compile against `mbedTLS`:

```
./configure --enable-tls-srp --with-mbedtls=/usr/local
make
sudo make install
```

## Back to Homebrew
Since I didn't want to fiddle with the `PATH`, I had to move the old `curl` out of the way:

```
sudo mv /usr/bin/curl /usr/bin/curl-old
sudo ln -s /usr/local/bin/curl /usr/bin/
```

The installation script needed some help:

```
curl -fsSLk https://raw.githubusercontent.com/Homebrew/install/master/install > install-homebrew
```

and I applied the necessary patch to get `curl` to allow insecure connections:

```
391c391
<     curl_flags += "k" if macos_version < "10.6"
---
>     curl_flags += "k" if macos_version <= "10.6"
```

Now, we can allow ruby to finish its work:

```
ruby install-homebrew
```

Homebrew dutifully informs us that OSX 10.6 is unsupported, so we're on our own; evidently, this is fine with me.

Our lack of certs is still an issue though; we'll have to set `cURL` to allow insecure connections by placing `insecure` in `~/.curlrc` and prepend all of our Homebrew commands with `HOMEBREW_CURLRC=~/.curlrc`.

So, running

```
HOMEBREW_CURLRC=~/.curlrc brew update --force
```

finishes the job.
Homebrew wasn't necessarily a requirement, but it'd be a pain to have to go through this later when I'd really like to get something working.
Of course, this isn't the end of the story when it comes to getting Homebrew working, because OpenSSL (a `git` build requirement, since apparently our funny git installation doesn't work...) doesn't build right away, but that's for another time.

## Installing TeXLive

I've already decided at this point to use Emacs exclusively as an editor; I've been a Vim, and subsequently [Spacemacs](http://spacemacs.org)/Evil user since the former is the most user-friendly editor we had installed on the servers I grew up with, and the keybindings are addictive, but I've been sufficiently evangelized to take the plunge.
This is an aside, but I would say that Spacemacs is an excellent way to transition over, particularly since you get so much of the kitchen sink with respect to IDE support, and the interface is just about halfway inbetween Vim & Emacs.

Now, TeXLive 2013 is apparently the newest version that will run successfully on this machine, and it's not available through the regular mirrors anymore.
The torrent network provides an installer though; I was able to install a minimal torrent client and grab the corresponding installer (if only a 2013 BasicTeX installer were available... too bad.)

I had to freeze the package repository that `tlmgr` uses:

```
sudo tlmgr option repository ftp://tug.org/historic/systems/texlive/2013/tlnet-final
```

after which `tlmgr` itself needed updating:

```
sudo tlmgr update --self
```

after which I finally got some new files to compile on this ancient machine!
So there you have it, continuous integration works, even in reverse.

## Future Work

* Check how to update the certifications once and for all on this machine. This would have been so much easier, but without being able to search effectively without them, it's a kind of chicken-and-egg problem.
I would note that I'll not be downloading software regularly on this machine, but having to do so much of this insecurely doesn't feel great...

* How much of "the world" would have to be built to get anything approaching a usable Julia installation going? What about Octave? Tensorflow? So many questions I don't want to consider right now... :-)
