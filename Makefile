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
HUGO_VERSION:=0.118.2

# Set path to Extended version of Hugo
ifeq (${UNAME},Darwin)
HUGO_DOWNLOAD_PATH:=https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_darwin-universal.tar.gz
endif
ifeq (${UNAME},Linux)
HUGO_DOWNLOAD_PATH:=https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_Linux-64bit.tar.gz
endif

# https://gohugo.io/getting-started/installing
${HUGO}.tar.gz:
	mkdir -p $(dir $@)
	curl -L ${HUGO_DOWNLOAD_PATH} -o $@
.PRECIOUS: ${HUGO}.tar.gz
$(HUGO):
	${MAKE} ${HUGO}.tar.gz ;				\
	cd bin && tar xvzf hugo.tar.gz ;
.PRECIOUS: ${HUGO}

.PHONY: hugo-env
hugo-env: $(HUGO)
	$(HUGO) --help
	$(HUGO) version
	$(HUGO) env

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
HUGOFILE:=hugo.toml

serve: $(HUGOFILE) $(HUGO) ## Serve page for local development
	$(HUGO) --disableFastRender server
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

# Sizes for icon file
icoSizes:=16 32 48 128 256
static/img/favicon.ico: static/img/favicon-master.svg
	$(foreach _icoSize,$(icoSizes),inkscape -w $(_icoSize) -h $(_icoSize) -o static/img/favicon-$(_icoSize).png $<;)
	convert $(addsuffix .png,$(addprefix static/img/favicon-,$(icoSizes))) $@
	identify $@ || echo 'Failed to identify.'
	$(RM) $(addsuffix .png,$(addprefix static/img/favicon-,$(icoSizes)))
.SECONDARY: static/img/favicon.ico

static/img/apple-touch-icon.png: static/img/favicon-master.svg
	inkscape -w 256 -h 256 -o $@ $<
.SECONDARY: static/img/apple-touch-icon.png

static/img/sharing-default.png: static/img/linkedin-featured.svg
	inkscape -w 1200 -h 630 -o $@ $<

static/img/logo-small.png: static/img/logo-pacifico.svg
	inkscape -w 241 -h 42 -o $@ $<

static/img/logo.png: static/img/logo-pacifico.svg
	inkscape -w 321 -h 56 -o $@ $<

# List of images to create under static/img
IMG_CONVERT:=									\
logo-small.png									\
logo.png										\
sharing-default.png								\
apple-touch-icon.png							\
favicon.ico

static/img/banners/%.png: static/img/banners/%.svg
	inkscape -w 890 -h 890 -o $@ $<
# https://www.google.com/search?q=opengraph+image+size&client=safari&rls=en&ei=SguCYIawEc7V-gS7gZvQDg&oq=opengraph+image+size&gs_lcp=Cgdnd3Mtd2l6EAMyBAgAEAoyBAgAEAoyBAgAEAoyBAgAEAoyBAgAEAoyBAgAEAoyBAgAEAoyBggAEAoQHjIGCAAQBRAeOgcIABBHELADOgUIIRCrAjoHCCEQChCrAjoFCAAQzQJQ2DFY77sBYN-9AWgKcAJ4AIABvAGIAacSkgEEMjcuMpgBAKABAaoBB2d3cy13aXrIAQjAAQE&sclient=gws-wiz&ved=0ahUKEwiG_ZiGhZPwAhXOqp4KHbvABuoQ4dUDCA4&uact=5
# https://neilpatel.com/blog/open-graph-meta-tags/

# List of images to create under static/img/banners
IMG_BANNERS:=									\
undraw_Project_completed_re_pqqq.png			\
undraw_Source_code_re_wd9m.png					\
undraw_design_components_9vy6.png				\
undraw_visual_data_re_mxxo.png					\
undraw_stars_re_6je7.png						\
undraw_Walk_in_the_city_re_039v.png				\
undraw_Map_dark_re_36sy.png

# List of images to create under static/img/clients
IMG_CLIENTS:=nike.png
static/img/clients/nike.png: static/img/clients/nike.svg
	inkscape -w 420 -h 150 -o $@ $<
.PHONY: static/img/clients/nike.png

## Generate banner images, which have to be PNG...
img-deps: $(addprefix static/img/banners/,${IMG_BANNERS}) $(addprefix static/img/,${IMG_CONVERT}) $(addprefix static/img/clients/,${IMG_CLIENTS}) ## Generate images for site
.PHONY: img-deps

### Generate site
generate: $(HUGO) $(HUGOFILE) img-deps ## Generate website
	$(HUGO) --minify --printI18nWarnings --printMemoryUsage --printPathWarnings --printUnusedTemplates --templateMetrics --templateMetricsHints
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


## Management commands for individual content pages
send-python-flask-crud-application: content/blog/python-flask-crud-application.py
	gist -d "Python Flask CRUD Application Boilerplate" -f app.py -R $<

PYTHON_FLASK_CRUD_APPLICATION_GIST:=https://gist.github.com/jgoldfar/72e5f0cea17d4306a91edb48401a1039
update-python-flask-crud-application: content/blog/python-flask-crud-application.py
	gist -U ${PYTHON_FLASK_CRUD_APPLICATION_GIST} $<

PYTHON_HASHTABLE_GIST:=https://gist.github.com/jgoldfar/56e758e460cd7e9c5ae60395e37cce15
send-python-hashtable: content/blog/python-hashtable.py
	gist -d "Python Hash Table" -f hashtable.py -R $<

# TODO replace reference with {{<gist jgoldfar 56e758e460cd7e9c5ae60395e37cce15 >}}
update-python-hashtable: content/blog/python-hashtable.py
	gist -U ${PYTHON_HASHTABLE_GIST} $<
