# We start by defining the path to this Makefile by parsing MAKEFILE_LIST.
# This allows referring to dependencies in a precise way
THIS_MAKEFILE_PATH:=$(abspath $(lastword $(MAKEFILE_LIST)))
LOCAL_BASE_PATH:=$(patsubst %/,%,$(dir $(THIS_MAKEFILE_PATH)))

# Print usage message (this must be first to avoid running something else when running
# `make` with no arguments on non-compliant Make variants)
usage:
	@echo "Usage: make [target] [VAR=VALUE...]"
	@echo "This Makefile defines automations and processes for my personal website."
	@echo "For detailed documentation, look to the Makefile."
	@echo ""
	@echo "Targets:"
	@$(MAKE) help 2>/dev/null
	@echo ""
	@echo "We benefit from the UX and parallelism of make, so we can run e.g."
	@echo "- make -j4 ..."
	@echo " to install your dotfiles at blazing speed (ha), or run "
	@echo "- make -k ..."
	@echo " to allow installation failures. Run as"
	@echo "- make --silent ..."
	@echo "to reduce the build verbosity, etc."
	@echo "See make --help or man make for more details"
# PHONY targets aren't considered to depend on anything, so they will always be generated.
# or run.
.PHONY: usage
# Set usage message to run when the user enters `make`
.DEFAULT_GOAL:=usage

## Autogenerate Help Info
# Borrowed from https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
# Any target with two comment symbols is listed.
.PHONY: help
help: ## Display this help section
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-38s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)


SHELL:=/bin/bash
UNAME:=$(shell uname -s)
HUGO:=bin/hugo
HUGO_VERSION:=0.67.1

ifeq (${UNAME},Darwin)
HUGO_DOWNLOAD_PATH:=https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_macOS-64bit.tar.gz
endif
ifeq (${UNAME},Linux)
HUGO_DOWNLOAD_PATH:=https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_Linux-64bit.tar.gz
endif

# https://gohugo.io/getting-started/installing
${HUGO}.tar.gz:
	curl -L ${HUGO_DOWNLOAD_PATH} -o $@
.PRECIOUS: ${HUGO}.tar.gz
$(HUGO):
	if ! command -v hugo ; then					\
		${MAKE} ${HUGO}.tar.gz ;				\
		cd $(dir $<) && tar xvzf $(notdir $<) ;	\
	fi
.PRECIOUS: ${HUGO}

### CV/Resume
CVDownloadPath:=https://dl.bintray.com/jgoldfar/ResumePublic/
CVPath:=static/cv


CVBibFiles:=cont-talks.bib inv-talks.bib posters.bib pubs.bib
CVFiles:=cv-default.pdf res-default.pdf $(CVBibFiles)

# Accumulator for cv-deps
CV_DEP_TARGETS:=

# Define template for downloading a single cv file using curl
define CVPULL_template
$$(CVPath)/$(1):
	mkdir -p $$(CVPath)
	curl -L "$$(CVDownloadPath)/$(1)" -o $$@
CV_DEP_TARGETS+=$$(CVPath)/$(1)
endef

# Evaluate the template above for each file in CVFiles
$(foreach file,$(CVFiles),$(eval $(call CVPULL_template,$(file))))

cv-deps: ${CV_DEP_TARGETS} ## Pull in CV files. There must be a better way!
.PHONY: cv-deps

# Download bibtex 2 bibjson converter from github repo
deps/bib2json.py:
	curl -L "https://raw.githubusercontent.com/jgoldfar/bibserver/jgoldfar-bibtexparser-23-support/parserscrapers_plugins/bibtex.py" -o $@
	chmod a+x $@
.PHONY: deps/bib2json.py

# Convert bibfile into bibJSON files
data/cv/%.json: $(CVPath)/%.bib deps/bib2json.py
	mkdir -p $(dir $@)
	cat $< | deps/bib2json.py > $@
	-cp $@ $(subst -,,$@)

cv-bibjson-datafiles: $(addprefix data/cv/,$(CVBibFiles:.bib=.json)) ## Generate JSON files from CV bibliography
.PHONY: cv-bibjson-datafiles

clean-cv-deps:
	$(RM) -r $(CVPath)
.phony: clean-cv-deps
CLEAN_TARGETS+=cv-deps

## Hugo Generation
HUGOFILE:=config.toml

serve: $(HUGOFILE) $(HUGO) ## Serve page for local development
	$(HUGO) --disableFastRender --verbose server
.PHONY: serve

new: $(HUGOFILE) $(HUGO) ## Make a new post (not super useful, just trying out Hugo)
ifeq ($(FileName),)
	@echo "Usage: make new FileName=..."
	@echo "i.e. make new FileName=blog/newBlogPost.md"
else # FileName set
ifeq ($(basename $(FileName)),$(FileName))
	$(HUGO) new $(FileName).md
else # Already has an extension
	$(HUGO) new $(FileName)
endif # Switch on existence of extension
endif # Switch on definition of FileName
.PHONY: new

icoSizes=16 32 48 128 256
img-deps: static/img/favicon.ico static/img/apple-touch-icon.png ## Generate images for site

static/img/favicon.ico: static/img/favicon-master.svg
	$(foreach _icoSize,$(icoSizes),inkscape -w $(_icoSize) -h $(_icoSize) -o static/img/favicon-$(_icoSize).png $<;)
	convert $(addsuffix .png,$(addprefix static/img/favicon-,$(icoSizes))) $@
	identify $@ || echo 'Failed to identify.'
	$(RM) $(addsuffix .png,$(addprefix static/img/favicon-,$(icoSizes)))
.SECONDARY: static/img/favicon.ico

static/img/apple-touch-icon.png: static/img/favicon-master.svg
	inkscape -w 256 -h 256 -o $@ $<
.SECONDARY: static/img/apple-touch-icon.png

### Generate site
generate: $(HUGO) $(HUGOFILE) ## Generate website
	if command -v hugo ; then					\
		hugo --verbose --minify ;				\
	fi
	if ! command -v hugo ; then					\
		$(HUGO) --verbose --minify ;			\
	fi
.PHONY: generate

# https://gohugo.io/hosting-and-deployment/hosting-on-github/
### Below here not needed when pushing directly to Github
GitRepoName:=jgoldfar.github.io

# Note: CI environment variable is (or should be) only set on CI services.
# This is when config should be set.
init-git: ## Initialize git repository for Github Pages
	@echo "WIP"
	exit 1
	$(RM) -r $(GitRepoName)
ifdef CI
	git -C ./$(GitRepoName) config user.email "ci@bitbucket.org" || echo "email set failed."
	git -C ./$(GitRepoName) config user.name "Bitbucket CI" || echo "username set failed."
endif
.PHONY: init-git

generate-git: $(HUGOFILE) $(HUGO) ## Generate hugo site into git repository
	$(HUGO) --verbose --destination ${GitRepoName}
.PHONY: generate-git

push-git: ## Push generated changes to git repository
	[[ -d "${GitRepoName}" ]] || ( echo "No changes generated." ; exit 1 )
	git -C ./$(GitRepoName) add -A .
	git -C ./$(GitRepoName) commit -m "Update with changes generated by commit $(shell )" || echo "Nothing to commit."
	git -C ./$(GitRepoName) push || echo "No updates to content!"
.PHONY: push-git

clean-git:
	$(RM) -r ${GitRepoName}

deploy-git: init-git generate-git push-git clean-git ## Run full deployment to Github Pages
.PHONY: deploy-git



clean: ${CLEAN_TARGETS} ## Cleanup generated files
	$(RM) -r ${GitRepoName} public
	$(RM) ${HUGO} bin/LICENSE bin/README.md
.PHONY: clean
