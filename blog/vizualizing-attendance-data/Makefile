SHELL=/bin/bash

all: $(addsuffix .png,$(addprefix Busy-Hours-,Julia R Python))

Manifest.toml: Project.toml
	julia --project=. -e 'ENV["PYTHON"]="$(shell which python)"; using Pkg; Pkg.instantiate(); Pkg.build()'

Busy-Hours-Julia.png: example.jl Manifest.toml Swipes-Time-Only.csv
	PYTHON=$(shell which python) julia --project=. $<

# Assumes that you've configured R to be able to build from source on your
# platform, apparently...
init-packages-R:
	R -e 'install.packages("tidyverse")'

Busy-Hours-R.png: example.R Swipes-Time-Only.csv
	Rscript $<

Busy-Hours-Python.png: example.py Swipes-Time-Only.csv
	pythonw $<
