---
title: "Building GNU Octave From Source on OSX"
description: ""
tags: ["build-the-world", "OSS"]
weight: 0
draft: false
---

Below are the steps I followed to build [GNU Octave](https://www.octave.org) from source on my Mac, together with some binary dependencies.
My main motivation is improvement of the Octave environment as an alternative to MATLAB; my main reasons for pursuing this are elucidated on [my post on the topic]({{< ref "blog/why-oss.md" >}}), but in particular, let me just say that I've been bit once by a license expiration that brought a portion of my numerical work to a standstill in the past, and that seems like an unacceptable reason to allow progress to stop!
That instance actually motivated me to switch to [Julia](https://www.julialang.org), since even at version 0.3, it was a promising and inviting language, but Octave is nothing if not a practical choice: some codes will _never_ be ported to anyone's language of choice, and allowing legacy code (even of debatable utility) to die unnecessarily seems... cruel?
MATLAB, in particular, seems naturally opposed to "modern" continuous integration tools like Travis, so even if Octave exists only to enable automated assurance that code continues to run, that seems valuable.
Moreover, if it can be improved in any way (certainly a Sisyphean task), any step towards parity is a step away from absolute dependence on a closed-source implementation.

Building a package from source is always interesting, but building the package on OSX without too much complaining from the build system was another challenge; I chose to build some of the GNU packages rather than mess with my global (Homebrew) configuration.
I'll document the exact versions that worked on my setup below.
Anyways, enough blabbing, here's the steps, in their current form:

* Clone the Octave repository and update to the `release-4.4.1` tag:

```
hg clone https://www.octave.org/hg/octave
hg update -r 25771 # release-4.4.1
```

* Use Homebrew to download a few dependencies:

```
brew install autoconf automake gnuplot gcc hdf5 qt
```

* Set up a directory in which we'll build some other dependencies, including a Makefile to build each from source:

```
mkdir -p octave/deps
wget -O octave/deps/Makefile https://gist.github.com/jgoldfar/37312d6ee5834d85542b1e0b35e8db94/raw
wget -O octave/deps/qrupdate-1.1.2_Makeconf.patch https://gist.github.com/jgoldfar/4f8f295841d68248d93426f82ab6d931/raw
```

* Download [Bison v3.0.4](https://www.gnu.org/software/bison/), [Curl v7.60.0](https://curl.haxx.se/), [Gawk v4.2.1](https://www.gnu.org/software/gawk/), [Sed v4.5](https://www.gnu.org/software/sed/), [GL2PS v1.4.0](http://www.geuz.org/gl2ps/), [QHull v2015-7.2.0](http://www.qhull.org/), [FFTW v3.3.7](http://www.fftw.org/), [GLPK v4.65](https://www.gnu.org/software/glpk/), [OpenBLAS v](http://www.openblas.net/), [PCRE2-v10.31](https://www.pcre.org/), [QRUpdate v1.1.2](https://sourceforge.net/projects/qrupdate/), [Readline v8.0-alpha](https://ftp.gnu.org/gnu/readline/), [SuiteSparse v5.2.0](http://faculty.cse.tamu.edu/davis/suitesparse.html), and [icoutils v0.32.3](https://www.nongnu.org/icoutils/) to `deps`.

* Run `make install` from `deps`.

* From the main source directory, generate the configuration script using Autotools and configure the build:

```
./bootstrap --gnulib-srcdir=`pwd`/gnulib --bootstrap-sync
./configure --prefix=`pwd`/usr --without-sndfile --without-portaudio --without-sundials_nvecserial --without-sundials_ida --without-arpack --without-qscintilla --without-fltk --with-blas=`pwd`/usr/lib/libopenblas.a PKG_CONFIG_PATH="`pwd`/usr/lib/pkgconfig:/usr/local/opt/qt/lib/pkgconfig" PATH=`pwd`/usr/bin:/usr/local/opt/qt/bin:${PATH} LDFLAGS="-L`pwd`/usr/lib -L/usr/local/opt/qt/lib" CPPFLAGS="-I`pwd`/usr/include -I/usr/local/opt/qt/include"
```

* Build the package:

```
PATH=`pwd`/usr/bin:/usr/local/opt/qt/bin:${PATH} make
```

This will only get so far, perhaps due to our fussing with local dependencies...

* First, the path to `gl2ps` will need to be set:

```
install_name_tool -change libgl2ps.1.dylib `pwd`/usr/lib/libgl2ps.1.dylib `pwd`/src/.libs/octave-cli
install_name_tool -change libgl2ps.1.dylib `pwd`/usr/lib/libgl2ps.1.dylib `pwd`/src/.libs/octave-gui
install_name_tool -change libgl2ps.1.dylib `pwd`/usr/lib/libgl2ps.1.dylib `pwd`/libgui/.libs/liboctgui.4.dylib
install_name_tool -change libgl2ps.1.dylib `pwd`/usr/lib/libgl2ps.1.dylib `pwd`/libinterp/.libs/liboctinterp.6.dylib
install_name_tool -change libgl2ps.1.dylib `pwd`/usr/lib/libgl2ps.1.dylib `pwd`/libinterp/dldfcn/__init_gnuplot__.oct
install_name_tool -change libgl2ps.1.dylib `pwd`/usr/lib/libgl2ps.1.dylib `pwd`/libinterp/dldfcn/chol.oct
install_name_tool -change libgl2ps.1.dylib `pwd`/usr/lib/libgl2ps.1.dylib `pwd`/libinterp/dldfcn/__delaunayn__.oct
install_name_tool -change libgl2ps.1.dylib `pwd`/usr/lib/libgl2ps.1.dylib `pwd`/libinterp/dldfcn/__voronoi__.oct
install_name_tool -change libgl2ps.1.dylib `pwd`/usr/lib/libgl2ps.1.dylib `pwd`/libinterp/dldfcn/convhulln.oct
install_name_tool -change libgl2ps.1.dylib `pwd`/usr/lib/libgl2ps.1.dylib `pwd`/libinterp/dldfcn/qr.oct
install_name_tool -change libgl2ps.1.dylib `pwd`/usr/lib/libgl2ps.1.dylib `pwd`/libinterp/dldfcn/__init_gnuplot__.oct
```

* Then, the path to `qrupdate` will need to be fixed:

```
install_name_tool -change /usr/local/lib64/libqrupdate.1.dylib `pwd`/usr/lib/libqrupdate.dylib `pwd`/src/.libs/octave-cli
install_name_tool -change /usr/local/lib64/libqrupdate.1.dylib `pwd`/usr/lib/libqrupdate.dylib `pwd`/src/.libs/octave-gui
install_name_tool -change /usr/local/lib64/libqrupdate.1.dylib `pwd`/usr/lib/libqrupdate.dylib `pwd`/libgui/.libs/liboctgui.4.dylib
install_name_tool -change /usr/local/lib64/libqrupdate.1.dylib `pwd`/usr/lib/libqrupdate.dylib `pwd`/libinterp/.libs/liboctinterp.6.dylib
install_name_tool -change /usr/local/lib64/libqrupdate.1.dylib `pwd`/usr/lib/libqrupdate.dylib `pwd`/liboctave/.libs/liboctave.6.dylib
install_name_tool -change /usr/local/lib64/libqrupdate.1.dylib `pwd`/usr/lib/libqrupdate.dylib `pwd`/libinterp/dldfcn/__init_gnuplot__.oct
install_name_tool -change /usr/local/lib64/libqrupdate.1.dylib `pwd`/usr/lib/libqrupdate.dylib `pwd`/libinterp/dldfcn/chol.oct
install_name_tool -change /usr/local/lib64/libqrupdate.1.dylib `pwd`/usr/lib/libqrupdate.dylib `pwd`/libinterp/dldfcn/__delaunayn__.oct
install_name_tool -change /usr/local/lib64/libqrupdate.1.dylib `pwd`/usr/lib/libqrupdate.dylib `pwd`/libinterp/dldfcn/__voronoi__.oct
install_name_tool -change /usr/local/lib64/libqrupdate.1.dylib `pwd`/usr/lib/libqrupdate.dylib `pwd`/libinterp/dldfcn/convhulln.oct
install_name_tool -change /usr/local/lib64/libqrupdate.1.dylib `pwd`/usr/lib/libqrupdate.dylib `pwd`/libinterp/dldfcn/qr.oct
```

You can check manually that these changes took place by running e.g.

```
otool -L `pwd`/libinterp/dldfcn/qr.oct
```
and looking to the paths this binary is expecting the above libraries.

* Copy over some files for building `texinfo` documentation:

```
cp build-aux/texinfo.tex doc/interpreter/
cp deps/gawk-4.2.1/doc/it/epsf.tex doc/interpreter/
```

* _Now_ we should be able to finish the build:

```
PATH=`pwd`/usr/bin:/usr/local/opt/qt/bin:${PATH} make
```

* The check target should pass:

```
PATH=`pwd`/usr/bin:/usr/local/opt/qt/bin:${PATH} make check
```

* Then we can install Octave locally:

```
PATH=`pwd`/usr/bin:/usr/local/opt/qt/bin:${PATH} make install
```

* Oh no! More `oct` files!

```
for file in $( ls /Users/jgoldfar/Public/octave/usr/lib/octave/4.4.1/oct/x86_64-apple-darwin16.7.0/*.oct ); do otool -L $file | grep qrupdate; done
# This is no good!

for file in $( ls /Users/jgoldfar/Public/octave/usr/lib/octave/4.4.1/oct/x86_64-apple-darwin16.7.0/*.oct ); do install_name_tool -change /usr/local/lib64/libqrupdate.1.dylib `pwd`/usr/lib/libqrupdate.dylib $file ; done
for file in $( ls /Users/jgoldfar/Public/octave/usr/lib/octave/4.4.1/oct/x86_64-apple-darwin16.7.0/*.oct ); do install_name_tool -change libgl2ps.1.dylib `pwd`/usr/lib/libgl2ps.1.dylib $file ; done
```

* Finally, enjoy your Octave installation!
