---
title: "Mirroring Flaky Git Repositories"
tags: ["OSS", "DevOps"]
date: 2019-02-15T15:12:00-04:00
draft: true
---

As a Maxima user (and besides that, a user of open-source software dependent on code found all over the web) who occasionally hacks around the boundary of the Maxima and Lisp code that comprise the language, having an up-to-date mirror is essential.
I also build Maxima into docker images we use to generate documentation and code (I know, I know: why bother with preprocessing in a homoiconic language, when you could just execute the generated code immediately, but it's actually a pretty good tool for generating MATLAB code, and can be persuaded to output Python and other languages as well)
In the past, I've run into issues with the main Maxima repository [on Sourceforge](http://maxima.sourceforge.net/) not allowing me to `git fetch` or `git clone` at an inopportune time, so some time back I set up a GitHub clone, but it sat there becoming outdated most of the time.
Looks like a job for some automation!

Having a CI service manage the clone would be much nicer; I opted for Travis-CI, but the setup is simple enough that any old platform should work.
The finished result is [here](https://github.com/jgoldfar/Mirror-Maxima-Repo), where you can see the steps I followed to get the repository set-up.

The main difficulty was ensuring that Travis could push the cloned files back to GitHub, which requires authentication.


1) Generate a new key (easier to revoke if compromised)

```shell
ssh-keygen -t rsa -b 4096 -C "jgoldfar+docker@gmail.com" -f id_rsa -P ""
cat id_rsa.pub
```

2) Copy the public key to a [deploy key on GitHub](https://developer.github.com/v3/guides/managing-deploy-keys/#deploy-keys).

3) Encrypt the private key and store the encrypted version on the server:

```shell
travis encrypt-file id_rsa --add
rm id_rsa id_rsa.pub
git add id_rsa .travis.yml
```

Within the repository, I put all of the steps necessary to get a Travis `generic` environment ready and working on this process into the Makefile.
Not too bad!

## Future Work

* It would be nice to automatically rebase my testing branch onto the updated mirror
