---
title: "Installing Jupyter with IJulia and IRkernel"
date: 2018-11-02T14:55:00-04:00
tags: ["OSS", "DataViz", "Julia-lang", "R-lang"]
draft: false
---

In this post, I'll share the commands I followed to install [JupyterLab](https://jupyterlab.readthedocs.io/en/stable/) using [Miniconda](https://conda.io/docs/index.html) on an OSX platform, as part of the preparation I'm doing for our open source data analysis course; it's important to me that everyone is able to reproduce the examples on their own machine and experiment for themselves.

*Update* The installation of R, Julia, etc. are now automated for MacOS using Ansible; see [this post]({{< ref "blog/automating-personal-devops.md" >}}).
If you're following those directions, after installing Ansible and the corresponding playbook, simply run

```
ansible-playbook -i inventory --ask-become-pass --tags "mro,jupyter_ijulia" main.yml
```

The following is all executed from the command line, assuming that Julia is available as `julia` and R is available as `R`.

## Miniconda installation

Just to make things easier path-wise, I like to install packages "close" to my Homebrew installation:

```
sudo mkdir -p /usr/local/miniconda3
sudo chown jgoldfar /usr/local/miniconda3
```

Now, install things:
```
wget https://repo.continuum.io/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
bash Miniconda3-latest-MacOSX-x86_64.sh -f -p /usr/local/miniconda3
```

## JupyterLab Installation

Install:
```
conda install -c conda-forge jupyterlab
```

Check:

```
jupyter notebook --version # 5.7.0 at the time of this writing
```

To run Jupyter Notebook:
```
jupyter notebook
```

To run JupyterLab:
```
jupyter lab
```

## IJulia Installation

Install (using Julia installed as `julia`):
```
julia -e 'ENV["JUPYTER"]="`which jupyter`"; using Pkg; Pkg.add("IJulia")'
```

I have a shortcut defined in my `bashrc` file to run IJulia in the current directory, though this is only useful if you're using Julia's private (Conda) distribution of Jupyter:
```
alias notebook="julia -e 'using IJulia; notebook(dir=pwd())'"
```

Installing the kernel this way will allow you to simply run

```
jupyter notebook
```

and access all of the installed kernels in your global installation.
This kind of trade-off is common: you can keep your dependencies isolated and your environment reproducible at the expense of disk space and some convenience (of which the latter is easy to resolve) or bring everything into your global environment, which can hurt reproducibility later down the line.
This is why I prioritize the conversion of any script I've put into "production" into an actual package or module with tests run on a continuous integration service.

## IRkernel Installation

Install (using R installed as `R`)

```
brew install libgit2
R -e "install.packages('devtools')" -e "devtools::install_github('IRkernel/IRkernel')" -e "IRkernel::installspec(name = 'ir35', displayname='R 3.5')"
```

## Check your Jupyer installation

```
jupyter notebook # or jupyter lab
```

You should be able to open a notebook in each of Julia, Python, and R; to check that all of the core functionality is available:

Julia:
```
GeneralizedHarmonicNumber=sum(1/i^2 for i in 1:100)
```

Python:
```
import math
GeneralizedHarmonicNumber=sum([math.pow(i, -2) for i in range(1, 101)])
print(GeneralizedHarmonicNumber)
```

R:
```
GeneralizedHarmonicNumber <- sum(sapply(1:100, function (i) 1/(i**2), simplify=TRUE))
```

*Note:* In order to export PDF files from Jupyter, you'll need a [TeX](http://tug.org/) installation; TeXLive/MacTeX will have all of the required packages, but if you're a [BasicTeX](http://tug.org/mactex/morepackages.html) user like myself, you'll need at least `adjustbox`, `collectbox` and `ucs` installed from CTAN.
