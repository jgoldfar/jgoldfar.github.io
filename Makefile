RSYNC=rsync -a

site.yaml-old: site.yaml
	cp $< $@

push-mac:
	hyde gen
	echo "moving deploy/ to /Volumes/jgoldfar/public_html"
	$(RSYNC) ./deploy/* /Volumes/jgoldfar/public_html

push-IWS:
	hyde gen
	echo "moving deploy/ to /media/udrive/public_html"
	$(RSYNC) ./deploy/* /media/udrive/public_html

push-git: github.site.yaml site.yaml-old
	cp github.site.yaml site.yaml
	hyde gen
	mv site.yaml-old site.yaml
	echo "moving deploy/ to jgoldfar.github.io subdirectory."
	$(RSYNC) ./deploy/* ./jgoldfar.github.io/
	-cd ./jgoldfar.github.io && git commit -am "Update with changes generated upstream" && git push

clean:
	-rm -r deploy