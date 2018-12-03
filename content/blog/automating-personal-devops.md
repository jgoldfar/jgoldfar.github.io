---
title: "Personal DevOps: using Ansible"
tags: ["DevOps"]
date: 2018-12-03T15:28:00-04:00
draft: false
---

I've now been in the position of setting up my build environment on multiple Mac computers
in the past couple weeks.
It can be a real impediment to my productivity when things (software, resources) aren't in the places I expect:
search for the missing package, download, build, and install it (dealing with any issues as they come up), etc.

Luckily, as a copious note-taker I already know where to find most packages I end up needing, and the steps I'll
need to complete to get things built.
But it's still a lot of "manual" work, and quite a bit of that is sensitive to the order operations are performed.

This is the perfect opportunity to learn a new tool, since I'm also familiar with the concept of configuration
management, "IT-speak" for the use-case I've found.
I experimented a bit with [Terraform](https://www.terraform.io) and [Puppet](https://puppet.com), and while these are expressive tools, I found their "focus" was a bit outside my needs, so I landed on [Ansible](https://www.ansible.com).
Now that this is all automated, I can just share [the link](https://github.com/jgoldfar/mac-dev-playbook) to the result of this experiment, and its build status: [![Build Status](https://travis-ci.org/jgoldfar/mac-dev-playbook.svg?branch=master)](https://travis-ci.org/jgoldfar/mac-dev-playbook) but I'll share the basics of what I learned about Ansible below, and as an "appendix", the sequence of steps I used to have to complete.
This new solution actually sets things up _much_ nicer than when I had to do everything "by hand".

The fundamental object in Ansible is a *playbook*, which contain a sequence of steps or tasks the software will complete.
Ansible has access to a wide variety of built-in functionality, as well as community-contributed packages through [Ansible Galaxy](https://galaxy.ansible.com).
The core functionality relates to ensuring that files are in place, and (using templates) constructing them if necessary, as well as installing packages and shelling out when necessary.

I'm sure my playbook isn't terribly idiomatic (I would note that MacOS isn't quite a first-class citizen with Ansible, it seems) and there's much more that Ansible can do to make my life easier, it wasn't too difficult to use Ansible's functionality to automate all of the package installation, setting of settings, etc.
Moreover, the playbook can be tested through Travis' CI infrastructure, so I'll know when I go to set up my next workstation whether I can expect everything to work or not.
By using Ansible's tag feature, the separate build steps can be shared: obviously, cloning my monorepo isn't terribly useful for anyone else, but if you'd like to (for instance) install BasicTeX, spacemacs, and my "Open in Emacs" automator workflow, you could follow the directions at the repository above, and run

```
ansible-playbook -i inventory --ask-become-pass --tags "basictex,spacemacs,openInEmacs" main.yml
```

Take a look and leave a comment or question!

## Future Work

* Add TeX package installation to playbook.

* Leverage Ansible's git repository management to replace my semi-automated version of the same.

* Complete a Linux playbook (I have a collection of similar notes for Linux...)

* Abstract away the PATH settings currently growing in my `.bashrc` file by adding paths during package installation, or template it completely using Ansible.

* Consider contributing some more generally useful tasks back to Ansible Galaxy

## Manual Setup Steps

1) Get [Homebrew](https://brew.sh/)

2) Start installing homebrew packages. Minimal list:

    autoconf automake aspell cmake curl gcc imagemagick mercurial python sbcl stow bash-completion

2a) Install `gnuplot`

    brew install --verbose gnuplot --with-cairo --with-latex --with-pdflib-lite

3) Generate new SSH keys and install them on bitbucket and github.

    ssh-keygen
    ssh-add -K ~/.ssh/privateKeyFile

3a) To avoid issues in the future, add those identities to `~/.ssh/config`, which should look as follows:

```
Host bitbucket
  HostName bitbucket.org
  User hg
  IdentityFile ~/.ssh/id_bitbucket

Host github
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_github
```

3b) It is convenient to generate keys for code01.fit.edu and any other servers I regularly access; a similar command to that above will generate them, and they can be installed by running, for instance,

```
ssh-copy-id -i ~/.ssh/privateKeyFile jgoldfar@code01.fit.edu
```

4) After `mercurial` is available, hg clone main CMS into Documents directory.

    hg clone ssh://hg@bitbucket.org/jgoldfar/jgoldfar-cms ~/Documents

This will likely require some manual clones using --uncompressed ,since the clone takes so darn long. In particular, I had to run

    hg clone --uncompressed ssh://hg@bitbucket.org/jgoldfar/researchrepos research
    hg clone --uncompressed ssh://hg@bitbucket.org/jgoldfar/ugradfiles ugrad

among other things.

5) Stow files from `Documents/misc/env` and `Documents/misc/tex-include`

    make -C ~/Documents/misc/env stow
    make -C ~/Documents/misc/tex-include stow

6) Initialize my Public directory how I like it:

6a) Clone public files:

    cd ~/Public
    hg clone ssh://hg@bitbucket.org/jgoldfar/publicfiles ~/Public/publicfiles
    mv publicfiles/* .
    mv publicfiles/.hg .
    mv publicfiles/.hgignore .


6b) git clone [Julia](https://julialang.org/) and [maxima](http://maxima.sourceforge.net/) into `~/Public`

    cd ~/Public
    git clone git@github.com:JuliaLang/julia.git
    git clone git@github.com:jgoldfar/maxima-clone.git maxima

and follow the directions in `Public/README.md`.

6c) in `maxima` directory, run

    ./bootstrap
    ./configure —-prefix=`pwd`/usr AND OTHER OPTIONS
    make && make install

6d) in `julia` directory, run `make` (that should do it.)

7) Install Spacemacs, and its dependencies:

7a) Install the font I use:

    brew tap caskroom/fonts
    brew cask install font-source-code-pro --fontdir=/Library/Fonts

7b) Install emacs

    brew tap d12frosted/emacs-plus
    brew install emacs-plus --without-spacemacs-icon

7c) Install [spacemacs](http://spacemacs.org/)

    git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d

7d) Install [the Automator workflow](https://bintray.com/jgoldfar/BlogPostSources/download_file?file_path=OpenInEmacs.tar.gz) I created to add an "Open in Emacs" command to the service menu.

8) Install [Spectacle](https://www.spectacleapp.com/), [SmartGit](https://www.syntevo.com/smartgit/), [VSCode](https://code.visualstudio.com/), [Skim](https://skim-app.sourceforge.io/), and [Firefox](https://www.mozilla.org/en-US/firefox/new/)

8a) Set up Skim reverse search for emacs: under the "Sync" preference pane, set the command as `/usr/local/bin/emacsclient` and arguments to `--no-wait +%line "%file"`.

9) Download the source for tortoisehg

13) Install QLStephen (https://github.com/whomwah/qlstephen)


### Note

* The ruby package included with OSX will not allow you to do much, in particular, its SSL version is very outdated. If you install a ruby tool, like `gist`, you'll have to follow Homebrew's instructions for making sure that your new ruby is called first in the PATH.
