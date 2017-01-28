RSYNC=rsync -a
ARGLocalDir=AlgebraReadingGroup
ARGFSPath=../../AlgebraReadingGroup
ARGCoursePath=content/course/AlgebraReadingGroup

site.yaml-old: site.yaml
	cp $< $@

### Dependencies
pull-deps: reading-group-deps

reading-group-deps:
	hg clone $(ARGFSPath) $(ARGLocalDir) || hg pull --cwd $(ARGLocalDir)
	hg update --cwd $(ARGLocalDir)
	$(MAKE) -C $(ARGLocalDir) hersteinExercises.pdf munkresExercises.pdf
	mv $(ARGLocalDir)/hersteinExercises.pdf $(ARGCoursePath)
	mv $(ARGLocalDir)/munkresExercises.pdf $(ARGCoursePath)
	mv $(ARGLocalDir)/index.htm $(ARGCoursePath)

### Push targets
push-git: github.site.yaml site.yaml-old pull-deps
	cp github.site.yaml site.yaml
	hyde gen
	mv site.yaml-old site.yaml
	echo "moving deploy/ to jgoldfar.github.io subdirectory."
	$(RSYNC) ./deploy/* ./jgoldfar.github.io/
	-cd ./jgoldfar.github.io && git commit -am "Update with changes generated upstream" && git push

clean:
	$(RM) -r deploy
	$(RM) -r $(ARGCoursePath)
	$(RM) -r $(ARGLocalDir)
