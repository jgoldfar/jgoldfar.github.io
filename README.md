## Personal Website Generator for Jonathan Goldfarb

* v2024.0

Generated using [Hugo](http://gohugo.io/), orchestrated using Github Actions on a Unix-like platform with `make`, `curl`, and `git`.

My website is currently being hosted [by github Pages](http://jgoldfar.github.io/).

### Usage

First, clone this repository somewhere; to install all of the remotely generated sources, run
```sh
make img-deps
```

For the most part, the build is "vanilla" Hugo, so a standard Hugo integration works without modification for this content.
The theme is a vendored and customized version of the [universal theme](//github.com/devcows/hugo-universal-theme), with all due credit to the creator.
Support their work!

As documented in the CI file [`bitbucket-pipelines.yml`](./bitbucket-pipelines.yml) or the [`.github`](./.github) workflow, it is enough to run `hugo --verbose --minify`, equivalent to `make generate`, to generate the static pages.

### Other Useful Commands

To make more significant changes to the pages, it is recommended to run `hugo` as a server, using

    make serve

To generate a new page (in particular, to automatically set the date) run

    make new FileName=...

For example, to make a new blog post with the title `230203ImplicitFunctionTheoremApplications`, run

    make new FileName=posts/230203ImplicitFunctionTheoremApplications

## References

- [Raw HTML From](https://anaulin.org/blog/hugo-raw-html-shortcode/)
