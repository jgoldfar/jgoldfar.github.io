---
title: "Why Open Source Software?"
tags: ["OSS"]
draft: false
date: 2018-08-15
---

These days, free and open source software (FOSS) is in vogue across many fields, both in academia and in industry, though there are holdouts, and it's not always the path of least resistance.
I'm not here to evangelize for open source, and I'm not a purist: closed-source and proprietary work has its place in our society.
However, when it comes to research, it seems to me that open source should be the default, for the libraries and products we make, as well as the tools we use to make them.
I'm not sure that anyone needs to be convinced, but nevertheless I'm going to record a few arguments I've made for pursuing and contributing to open-source software, particularly for scientific work.
I'll do my best not to pick on particular software tools!

* Your output is only as accurate as the underlying tools, and without the _ability_ to check those tools and libraries, you can never be sure if your results are as true as possible.
Of course, this reasoning extends all the way down the the "bare metal", [with potentially troubling consequences](https://en.wikipedia.org/wiki/Pentium_FDIV_bug), but when faced with a potential bug (or new result!) it seems reasonable to check at least a layer or two in your computational stack for potential flaws.

* Related to the reason above, the more educated eyes pass over a portion of code, the more likely it is to be corrected if wrong.
No matter the expertise available at large firms, there's simply no way to duplicate the "web-scale" possibility of open-source development.
This can result in both increased correctness and performance; one example comes to mind: in one of my research areas, I solve (many) PDEs numerically as part of an optimization process.
With enough time, just about anyone could develop the breadth and depth of knowledge necessary to implement custom optimization routines, time-stepping algorithms, linear solvers for sparse matrices, floating point arithmetic, and so on; sure, I've written more or less sophisticated PDE solvers and linear algebra routines, but I'm not an expert: I trust experts to work on those problems, enabling me to experiment with far better codes than I could produce in a reasonable amount of time.

* With a closed-source offering, the reproducibility of your results is contingent on the continuing existence of your license as well as firm offering the software.
If the version of a closed-source tool used to produce your work is unsupported, too bad!
Unmaintained FOSS exists, no doubt, but it is nearly trivial to [_begin_]({{< ref "blog/maintaining-legacy-website-hyde.md" >}}) maintaining an abandoned piece of available software (getting it to actually build correctly is another thing...)
This point comes from experience, as my university once (quite controversially) decided to drop their MATLAB license, and some of the codes I was using to produce my research results were only implemented in MATLAB files.
After writing shim code to get the package to work on [Octave]({{< ref "blog/building-octave-osx.md" >}}), the open source competitor, I found an almost two order-of-magnitude slowdown, meaning that the PDE constrained optimization codes that previously took perhaps an hour to complete a parameter sweep over a region of interest would become simply impractical to continue using.
Octave has definite value, but it wouldn't fit my use-case.
Taking to the internet in search of a solution, [Julia](https://julialang.org/) (then only at version 0.2) appeared to promise a scientific computing local optimum: fast, expressive, and (as I would come to find) relatively safe.
Julia has come a long way since then, and a more complete discussion of OSS tools is out of scope for this page, but most importantly, it was free and open source: once I had the source code, my work could never again be blocked arbitrarily, and in principle, all codes I wrote could be reprodicibly run against the same codebase indefinitely.

* FOSS democratizes the scientific process: there is no reason to expect that the ability to spend money on software is correlated with ability or intelligence.
Producing work that _requires_ non-free software to reproduce is exclusionary.
Much of the scientific work in USA is funded, at least in part, by the public, and the results are made available to the public.
However, if those results are based on an opaque analysis, I'm not sure one can say that taxpayers have received all they paid for.
Within or without the USA, it seems reasonable to assert that the most lasting effect humanity will have on the universe is the dissemination of information; the production of order out of chaos, in some way.
What a shame it would be for all of that information to be indecipherable (perhaps, again, appearing random) because we chose the path of least resistance.

Though my code may not be particularly good, and not all of it can (or will) be open-sourced, take a look [here](/oss-contributions/) for some of what I've done.
