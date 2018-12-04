---
title: "Installing R (MRO) on OSX Sierra"
date: 2018-11-02T11:49:00-04:00
tags: ["OSS", "R-lang"]
draft: false
---

As someone who works regularly with various statistical and scientific software stacks (I always say I prefer to use the best tool for the job, rather than fitting my favorite tool into every job) I am pretty impressed by the leaps in visibility R has taken in the past few years.
I first used R for a "big data" project years ago (for a size of N too large for Excel, not what one would consider "big" these days...) and in the intervening years have worked with R in my teaching and for statistical analysis projects intermittently, but without stepping back and looking at all of the progress that has been made!
So when I started a new data analysis project (on a newly formatted machine, no less), I figured it might be time to update my R setup.

[Microsoft R Open (MRO)](https://mran.microsoft.com/open) is [apparently](https://www.r-bloggers.com/a-data-scientists-perspective-on-microsoft-r/) the way to go, since it handles the integration of R with multithreaded libraries on multiple platforms; in the past, I've used Homebrew's installation, but figured I would give MRO a go.

*Update* The installation of MRO and the tidyverse. are now automated for MacOS using Ansible; see [this post]({{< ref "blog/automating-personal-devops.md" >}}).
If you're following those directions, after installing Ansible and the corresponding playbook, simply run

```
ansible-playbook -i inventory --ask-become-pass --tags "homebrew,mro" --extra-vars='{configure_tidyverse:yes}' main.yml
```


The installation process for MRO itself isn't too tricky, but since many R packages are written using C, C++, or Fortran code behind the scenes, a working compiler is required.
So here we turn to [Homebrew](https://brew.sh/): the GCC package provides compilers for each of those languages:

```
brew install gcc
```

However, they aren't provided in a location that R expects when installing packages.
To inform R where to find its dependencies, we set some variables in the file `~/.R/Makevars`:

```
VERSHORT=8
VERLONG=$(VERSHORT).2.0
VER=-$(VERSHORT)
CC=gcc$(VER)
CXX=g++$(VER)
CXX1X=g++$(VER)
CXX11=$(CXX1X)
CFLAGS=-mtune=native -g -O2 -Wall -pedantic -Wconversion
CXXFLAGS=-mtune=native -g -O2 -Wall -pedantic -Wconversion
FLIBS=-L/usr/local/Cellar/gcc/$(VERLONG)/lib/gcc/$(VERSHORT)
```

Note that you'll need to set `VERSHORT` and `VERLONG` according to the version installed by Homebrew in the previous step.
The added `CXX11` flag (which duplicates `CXX1X`) is apparently only necessary for `lubridate`, which doesn't respect the other flag.
With these environment variables set, we can now install our favorite packages:

```
install.packages("tidyverse")
```

Having that, the rest should *just work*:

```
library(ggplot2)

data <- data.frame(
  course=c("Calc 1", "Calc 2"),
  visitors=c(100, 20)
)

plot <- ggplot(
  data = data,
  aes(x=course, y=visitors)) +
  geom_bar(stat="identity")
ggsave("courseVisitors.pdf", plot=plot)
```
