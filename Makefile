SHELL:=/bin/bash
RSYNC:=rsync -a
UNAME:=$(shell uname -s)
HUGO:=bin/hugo

# https://gohugo.io/getting-started/installing
ifeq ($(UNAME),Darwin)
bin/hugo_extended_0.67.1_macOS-64bit.tar.gz:
	curl -L https://github.com/gohugoio/hugo/releases/download/v0.67.1/hugo_extended_0.67.1_macOS-64bit.tar.gz -o $@
$(HUGO): bin/hugo_extended_0.67.1_macOS-64bit.tar.gz
	cd bin && tar xvzf $(notdir $<)
endif

ifeq ($(UNAME),Linux)
bin/hugo_extended_0.67.1_Linux-64bit.tar.gz:
	curl -L https://github.com/gohugoio/hugo/releases/download/v0.67.1/hugo_extended_0.67.1_Linux-64bit.tar.gz -o $@
$(HUGO): bin/hugo_extended_0.67.1_Linux-64bit.tar.gz
	cd bin && tar xvzf $(notdir $<)
endif

## Dependencies
pull-deps: julia-pre-deps reading-group-deps cv-deps cal-deps oss-contribs-deps

## Julia package installation & instantiation
# Override JULIA variable to set a different Julia version
JULIA:=$(shell which julia)
# URI for Libical. Override with local path if setting LIBICALDEV=1
LIBICALURI:=https://github.com/jgoldfar/Libical.jl
# Use local development version of Libical (==1) or not (==0)?
LIBICALDEV?=0
julia-pre-deps:
ifeq ($(LIBICALDEV),0)
	$(JULIA) --project="." -e 'using Pkg; Pkg.add(PackageSpec(url="$(LIBICALURI)", rev="master"))'
else
	$(JULIA) --project="." -e 'using Pkg; Pkg.develop(PackageSpec(url="$(LIBICALURI)"))'
endif
	$(JULIA) --project="." -e 'using Pkg; Pkg.instantiate();'

### Algebra Reading Group
ARGDownloadPath:=https://bitbucket.org/jgoldfar/algebrareadinggroupnotes/downloads
ARGCoursePath:=static/AlgebraReadingGroup
ARGFiles:=hersteinExercises.pdf munkresExercises.pdf index.htm
InstallDirs+=$(ARGCoursePath)

reading-group-deps:
	mkdir -p $(ARGCoursePath)
	$(foreach file, $(ARGFiles), \
		curl -L "$(ARGDownloadPath)/$(file)" -o "$(ARGCoursePath)/$(file)"; \
	)

### CV/Resume
CVDownloadPath:=https://dl.bintray.com/jgoldfar/ResumePublic/
CVPath:=static/cv
InstallDirs+=$(CVPath)
CVBibFiles:=cont-talks.bib inv-talks.bib posters.bib pubs.bib
CVFiles:=cv-default.pdf res-default.pdf $(CVBibFiles)

# Define template for downloading a single cv file using curl
define CVPULL_template
cv-dep-pull-$(1): $$(CVPath)/$(1)

$$(CVPath)/$(1):
	mkdir -p $$(CVPath)
	curl -L "$$(CVDownloadPath)/$(1)" -o $$@
endef

# Evaluate the template above for each file in CVFiles
$(foreach file,$(CVFiles),$(eval $(call CVPULL_template,$(file))))

# cv-deps-pull calls each templated target
cv-deps-pull: $(addprefix cv-dep-pull-,$(CVFiles))

cv-deps: cv-deps-pull cv-bibjson-datafiles
	mv $(CVPath)/cv-default.pdf $(CVPath)/cv.pdf
	mv $(CVPath)/res-default.pdf $(CVPath)/res.pdf

# Download bibtex 2 bibjson converter from github repo
deps/bib2json.py:
	curl -L "https://raw.githubusercontent.com/jgoldfar/bibserver/jgoldfar-bibtexparser-23-support/parserscrapers_plugins/bibtex.py" -o $@
	chmod a+x $@

# Convert bibfile into bibJSON files
data/cv/%.json: $(CVPath)/%.bib deps/bib2json.py
	mkdir -p $(dir $@)
	cat $< | deps/bib2json.py > $@
	-cp $@ $(subst -,,$@)

cv-bibjson-datafiles: $(addprefix data/cv/,$(CVBibFiles:.bib=.json))

### Schedule/Calendar
# Note: Set these variables in the environment (in particular, on CI) for this target
# to work.
CourseAppointmentIcalLink?=
SeminarScheduleIcalLink?=
IcalPath:=deps/ical
InstallDirs+=$(IcalPath)
IcalTargetFiles:=$(addsuffix .ical,CourseAppointment SeminarSchedule)

# Pull ical files from given links
$(IcalPath)/CourseAppointment.ical:
	[ ! -z "$(CourseAppointmentIcalLink)" ]
	mkdir -p $(dir $@)
	@curl -L "$(CourseAppointmentIcalLink)" -o "$@"

$(IcalPath)/SeminarSchedule.ical:
	[ ! -z "$(SeminarScheduleIcalLink)" ]
	mkdir -p $(dir $@)
	@curl -L "$(SeminarScheduleIcalLink)" -o "$@"

cal-deps-pull: $(addprefix $(IcalPath)/,$(IcalTargetFiles))

## Generate schedule file from ical files
cal-deps-generate: deps/generateScheduleFile.jl Project.toml $(addprefix $(IcalPath)/,$(IcalTargetFiles))
	$(JULIA) --project="." $@ $(addprefix $(IcalPath)/,$(IcalTargetFiles))

cal-deps: cal-deps-pull


### OSS contribution/repository listing generator
# Note: These depend on deps/getRepos.jl and Project.toml
data/oss/github.json:
	mkdir -p $(dir $@)
	$(JULIA) --project="." deps/getRepos.jl $@ --github

data/oss/bitbucket.json:
	mkdir -p $(dir $@)
	$(JULIA) --project="." deps/getRepos.jl $@ --bitbucket

oss-contribs-generate: data/oss/github.json data/oss/bitbucket.json

data/oss/combined.json: $(addprefix data/oss/, github.json bitbucket.json)
	$(JULIA) --project="." -e "using JSON; open(\"$@\", \"w\") do st;  JSON.print(st, append!(map(JSON.parsefile, ARGS)...), 2); end" $^

oss-contribs-deps: data/oss/combined.json

## Hugo Generation
HUGOFILE:=config.toml

serve: $(HUGOFILE) $(HUGO)
	$(HUGO) --disableFastRender --verbose server

new: $(HUGOFILE) $(HUGO)
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

### Generate site
generate: $(HUGO) $(HUGOFILE)
	$(HUGO) --verbose

GitRepoName:=jgoldfar.github.io
gen-git: $(HUGOFILE) $(HUGO)
	$(MAKE) generate
	echo "moving public/ to $(GitRepoName) subdirectory."
	$(RSYNC) ./public/* ./$(GitRepoName)/
.PHONY: gen-git

# Note: CI environment variable is (or should be) only set on CI services.
# This is when config should be set.
init-git:
	if [[ ! -d $(GitRepoName) ]] ; then \
	git clone git@github.com:jgoldfar/$(GitRepoName).git ;\
	fi
	$(RM) -r $(GitRepoName)/*
ifdef CI
	git -C ./$(GitRepoName) config user.email "ci@bitbucket.org" || echo "email set failed."
	git -C ./$(GitRepoName) config user.name "Bitbucket CI" || echo "username set failed."
endif
.PHONY: init-git

push-git: init-git gen-git
	git -C ./$(GitRepoName) add -A .
	git -C ./$(GitRepoName) commit -m "Update with changes generated by hg commit $(shell hg log --limit 1 -T '{node}')" || echo "Nothing to commit."
	git -C ./$(GitRepoName) push || echo "No updates to content!"
.PHONY: push-git

clean:
	$(RM) -r public
	$(RM) -r $(InstallDirs)
	$(RM) -r jgoldfar.github.io
	$(RM) ${HUGO} bin/LICENSE bin/README.md
.PHONY: clean
