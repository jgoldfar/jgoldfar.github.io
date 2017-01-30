RSYNC=rsync -a

site.yaml-old: site.yaml
	cp $< $@

### Dependencies
pull-deps: reading-group-deps cv-deps

ARGLocalDir=deps/AlgebraReadingGroup
ARGFSPath=../../AlgebraReadingGroup
ARGCoursePath=content/course/AlgebraReadingGroup
reading-group-deps:
	mkdir -p $(ARGLocalDir)
	hg clone $(ARGFSPath) $(ARGLocalDir) || hg pull --cwd $(ARGLocalDir)
	hg update --cwd $(ARGLocalDir)
	$(MAKE) -C $(ARGLocalDir) hersteinExercises.pdf munkresExercises.pdf
	mkdir -p $(ARGCoursePath)
	cp $(ARGLocalDir)/hersteinExercises.pdf $(ARGCoursePath)/hersteinExercises.pdf
	cp $(ARGLocalDir)/munkresExercises.pdf $(ARGCoursePath)/munkresExercises.pdf
	cp $(ARGLocalDir)/index.htm $(ARGCoursePath)/index.htm

CVLocalDir=deps/CV
CVFSPath=../../../misc/resume
CVPath=content/media
CVFiles=cv.pdf res.pdf res_statement.pdf teach_statement.pdf
cv-deps:
	mkdir -p $(CVLocalDir)
	hg clone $(CVFSPath) $(CVLocalDir) || hg pull --cwd $(CVLocalDir)
	hg update --cwd $(CVLocalDir)
	$(MAKE) -C $(CVLocalDir) $(CVFiles)
	mkdir -p $(CVPath)
	cp $(CVLocalDir)/*.pdf $(CVPath)

### Push targets
gen-git: github.site.yaml site.yaml-old pull-deps
	cp github.site.yaml site.yaml
	hyde gen
	mv site.yaml-old site.yaml
	echo "moving deploy/ to jgoldfar.github.io subdirectory."
	$(RSYNC) ./deploy/* ./jgoldfar.github.io/

push-git: gen-git
	-cd ./jgoldfar.github.io && git commit -am "Update with changes generated upstream"
	-cd ./jgoldfar.github.io && git push

clean:
	$(RM) -r deploy
	$(RM) -r $(ARGCoursePath)
	$(RM) -r $(ARGLocalDir)
	$(RM) -r $(addprefix content/media/,$(CVFiles))
