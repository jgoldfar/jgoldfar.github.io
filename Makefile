SHELL=/bin/bash
RSYNC=rsync -a
UNAME=$(shell uname -s)
HUGO?=bin/hugo

ifeq ($(UNAME),Darwin)
$(HUGO): bin/hugo_0.40.3_macOS-64bit.tar.gz
	cd bin && tar xvzf $(notdir $<)
endif

ifeq ($(UNAME),Linux)
$(HUGO): bin/hugo_0.40.3_Linux-64bit.tar.gz
	cd bin && tar xvzf $(notdir $<)
endif

## Dependencies
pull-deps: julia-pre-deps reading-group-deps cv-deps cal-deps oss-contribs-deps

## Julia package installation & instantiation
# Override JULIA variable to set a different Julia version
JULIA?=$(shell which julia)
# URI for Libical. Override with local path if setting LIBICALDEV=1
LIBICALURI?=https://github.com/jgoldfar/Libical.jl
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
ARGDownloadPath=https://bitbucket.org/jgoldfar/algebrareadinggroupnotes/downloads
ARGCoursePath=static/AlgebraReadingGroup
ARGFiles=hersteinExercises.pdf munkresExercises.pdf index.htm
InstallDirs+=$(ARGCoursePath)

reading-group-deps:
	mkdir -p $(ARGCoursePath)
	$(foreach file, $(ARGFiles), \
		curl -L "$(ARGDownloadPath)/$(file)" -o "$(ARGCoursePath)/$(file)"; \
	)

### CV/Resume
CVDownloadPath=https://bintray.com/jgoldfar/ResumePublic/download_file?file_path=
CVPath=static/cv
InstallDirs+=$(CVPath)
CVBibFiles=cont-talks.bib inv-talks.bib posters.bib pubs.bib
CVFiles=cv@default.pdf res@default.pdf $(CVBibFiles)

cv-deps-pull:
	mkdir -p $(CVPath)
	$(foreach file, $(CVFiles), \
		curl -L "$(CVDownloadPath)/$(file)" -o "$(CVPath)/$(file)"; \
	)

cv-deps: cv-deps-pull cv-bibjson-datafiles
	mv $(CVPath)/cv@default.pdf $(CVPath)/cv.pdf
	mv $(CVPath)/res@default.pdf $(CVPath)/res.pdf

deps/bib2json.py:
	curl -L "https://raw.githubusercontent.com/jgoldfar/bibserver/jgoldfar-bibtexparser-23-support/parserscrapers_plugins/bibtex.py" -o $@
	chmod a+x $@

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
IcalTargetFiles=$(addsuffix .ical,CourseAppointment SeminarSchedule)

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
HUGOFILE := config.toml

serve: $(HUGOFILE) $(HUGO)
	$(HUGO) --verbose server

FileName?=
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

### Generate site
GitRepoName=jgoldfar.github.io
gen-git: $(HUGOFILE) $(HUGO)
	$(HUGO) --verbose
	echo "moving public/ to $(GitRepoName) subdirectory."
	$(RSYNC) ./public/* ./$(GitRepoName)/

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

push-git: init-git gen-git
	git -C ./$(GitRepoName) add -A .
	git -C ./$(GitRepoName) commit -m "Update with changes generated by hg commit $(shell hg log --limit 1 -T '{node}')" || echo "Nothing to commit."
	git -C ./$(GitRepoName) push || echo "No updates to content!"

clean:
	$(RM) -r public
	$(RM) -r $(InstallDirs)
	$(RM) -r jgoldfar.github.io
	$(RM) bin/hugo bin/LICENSE bin/README.md
