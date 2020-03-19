all: index.md

%.md: %.ipynb
	jupyter nbconvert "$<" --to=markdown --output="$@"

%.html: %.ipynb
	jupyter nbconvert "$<" --to=html --output="$@"

%-basic.html: %.ipynb
	jupyter nbconvert "$<" --to=html --template="basic" --output="$@"

%.slides.html: %.ipynb
	jupyter nbconvert "$<" --to="slides" --output="$@"
