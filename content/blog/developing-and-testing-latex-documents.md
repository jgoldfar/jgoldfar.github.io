---
title: "Developing and Testing LaTeX Documents"
tags: ["CI", "LaTeX"]
draft: true
---

I've been using TeX (in particular, LaTeX) for years, at this point; for mathematicians and many in the technical fields, it would be nearly impossible to work efficiently without some ability with the tool.
I've even offered my typesetting services semi-professionally, since programming in LaTeX is just tricky enough to _not_ be something to mess with on a deadline.
It's perhaps surprising to find the use of LaTeX is spreading, not diminishing: MathJaX an d KaTeX make the use of the syntax possible on the web, which means we can all avoid writing the objectively worse MathML, or exporting everything to image files, which would be unfortunate.
Apparently, it's a local minimum in the space of technical information input languages.

As a typesetting system, TeX could be considered a mixed bag: the learning curve can be steep, which can be an unfortunate barrier to entry, but the stability and quality of the output, as well as the possibility of integration with version control and content generation systems are nearly unrivaled.
As an educator, I believe the solution to the first problem is, of course, education, and careful selection of a template and documentation to get started.
From a pragmatic standpoint, the LaTeX macro package built on TeX provides a nice starting point, since it reduces the barrier of entry a bit, and enables the use of safer, semantically clear code to represent the writer's intent.
My own entry in the template category [is available here](), and since TeX is a programming language written in ASCII format, it integrates well with standard software engineering tools, which provide the same kinds of benefits that they do anywhere else.
In fact, even with one user, I would state that the utility of these kind of tools easily outweighs the one-time cost of learning LaTeX.
In this entry, I would like to share some of the tools I use to track and develop LaTeX documents.

## A Most Important Tool

The first and perhaps most essential recommendation I can make is to use a version control system.
There are myriad options available, but `git`, and to a lesser extend, `mercurial` have available free hosting services, which serve as a backup for what I would assume to be some of the most important documents you have around.
If you're going to be using a version control system, there are a couple rules-of-thumb to keep in mind when writing your document.

1) Version control tends to be most sensitive to per-line changes; since LaTeX only breaks a paragraph after an entire blank line, there's no harm in putting each sentence on its own line in the file.

2) When working on a file with multiple collaborators, or where certain content would be used in multiple places, using separate files can be easier.
At least one file per section or chapter is manageable, but search from TeX to the compiled file and vice-versa, which is supported by most editor-viewer combinations, you can feel free to use as many or as few files as you'd like.

## Build Tooling

One of the nice things about LaTeX is that you can start with a very simple document (containing only text and equations with no references, say) and compile it once with good results, but once in-text references, indexes, and other niceties are involved, one compilation won't work.[^1]

Unfortunately (or, depending on your point-of-view, fortunately) achieving visually pleasing output sometimes necessitates, for instance, moving an equation to another page, which can change page references: what is really necessary is to run the compiler and all of the supporting programs in the correct order until a fixed point is found.
That is exactly the intent of the [`Latexmk`](https://mg.readthedocs.io/latexmk.html) program; it encapsulates most of this compilation complication.

If you're comfortable programming in Perl, you can extend `latexmk` to handle just about any other need, but for many applications, using `make` is a bit more ergonomic.
A simple `Makefile` for the generation of a PDF file from a TeX file named `main.tex` would look like

```
LATEX=latexmk -pdf

main.pdf: main.tex
	$(LATEX) $<
```

Having this, generating your PDF file is as simple as running `make`, but if you like to be a bit more verbose, `make main.pdf`.

If you have multiple source files included into `main.tex`, you can teach `make` about these dependencies by building a list of TeX sources and putting them after `main.tex`.
In order to keep your work organized, I recommend to put your sub-files into their own directory (or directories), but that is, of course, optional.

```
SOURCES=$(wildcard subfile-directory/*.tex)
SOURCENAMES=$(basename $(SOURCES))
LATEX=latexmk -pdf

main.pdf: main.tex $(SOURCES)
	$(LATEX) $<
```

## Cleaning up

Because of its compilation strategy, TeX generates a bunch of auxiliary files, but `latexmk` has a built-in facility to clean up after itself.
The corresponding `Makefile` snippet looks like

```
clean-src-%: %.tex
	$(LATEX) -c $<

clean-all-src-%: %.tex
	$(LATEX) -C $<

clean-srcs: $(addprefix clean-src-,$(SOURCENAMES))

clean-all-srcs: $(addprefix clean-all-src-,$(SOURCENAMES))
```

Now, running `make clean-srcs` will remove all of the auxiliary files that `latexmk` knows about, and running `make clean-all-srcs` will remove auxiliary files as well as the output PDF.
You can also run other cleanup steps corresponding to each source file if you need to; for instance, if compiling `main.tex` generates `main.gnuplot`, you could add

```
$(RM) $*.gnuplot
```
to the corresponding target.
Be careful here to only remove those files you can regenerate automatically!

## Reference Management

Managing references really could be its own topic, with quite a few GUI applications and websites available that claim to help manage your research process.
We've all been through the process of learning to format citations and references according to APA, MLA, etc. formats: of course, the TeX ecosystem has come up with a solution to this problem, making reformatting and managing references a write-once situation.
I have found that the most widely supported option is [BibTeX](http://www.bibtex.org/); on my Mac, I now use BibDesk to manage the citations, but writing the necessary information by hand isn't too tricky.
In fact, the current recommendation is to keep one big reference file for all of your research, since you can always choose a subset and save it as a separate file for submission to a journal.
Take a look at the link above for more information on implementing BibTeX references in your paper; since this post is just about the build and testing process, I'll just show how the corresponding `Makefile` should look, assuming your references live in `refs.bib`:

```
SOURCES=$(wildcard subfile-directory/*.tex)
LATEX=latexmk -bibtex -pdf

main.pdf: main.tex refs.bib $(SOURCES)
	$(LATEX) $<
```

## Generating Calculations using Maxima

Now for some of the really fun stuff!
Though such calculations don't typically appear in journal articles, there is sometimes a need to complete tedious calculations and include the result in your TeX file.
[Maxima](http://maxima.sourceforge.net/) is a computer algebra system that supports operation on the command line as well as export to TeX.
I've found this particularly useful for generating step-by-step solutions to problems in quizzes.
To give a simple example, if we'd like to calculate an explicit form for the cube of four terms and export the result into `expand-four-term-cubes.tex`, we could put the following in `expand-four-term-cube.mac`

```
expandedTerm: expand((d1term + d2term + d3term + d4term)^3);

load("mactex-utilities")$
texput(d1term, "\\left[a_1\\right]")$
texput(d2term, "\\left[a_2\\right]")$
texput(d3term, "\\left[a_3\\right]")$
texput(d4term, "\\left[a_4\\right]")$
with_stdout("expand-four-term-cubes.tex", tex(expandedTerm))$
```

The directive `texput` tells Maxima how to typeset the corresponding internal symbols as TeX.
The resulting TeX file can be included directly into your main file by writing 

```
\input{expand-four-term-cubes}
```


## Footnotes

[^1]: The reason is a bit interesting: `pdflatex` is a one-pass compiler, so it produces the necessary information to get correct references and saves it to an `aux` file the first time it's run, and reads this information in on the second run.
Other compilation-type stages output intermediate information to files with other extensions; this is why clearing out all of the intermediate files is sometimes necessary to complete the compilation process: sometimes `latex` or another program writes invalid commands to an auxiliary file, which causes another compilation to break.