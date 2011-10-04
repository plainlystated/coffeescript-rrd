COFFEE_FILES:=$(shell find . -name \*.coffee -type f)
JS_FILES:=$(subst coffee,js,$(COFFEE_FILES))

all: $(JS_FILES)

test: $(JS_FILES)
	vows --spec test/*-test.js

%.js: %.coffee
	coffee --compile $^

clean:
	rm $(JS_FILES)
