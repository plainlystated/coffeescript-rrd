COFFEE_FILES:=$(shell find . -name \*.coffee -type f)
JS_FILES:=$(subst coffee,js,$(COFFEE_FILES))

all: $(JS_FILES)

%.js: %.coffee
	coffee --compile $^

clean:
	rm $(JS_FILES)
