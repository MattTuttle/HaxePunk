COMMAND=haxe
TARGET=hl
TEST=openfl4

.PHONY: all doc docs haxelib examples unit test build clean

all: clean unit docs examples

docs:
	@echo "Generating documentation"
	@haxe docs.hxml
	@lix run dox -i doc/xml -o doc/pages/ \
		--include "haxepunk" \
		--exclude "haxepunk.backend" \
		--title "HaxePunk" \
		-D source-path "https://github.com/HaxePunk/HaxePunk/tree/master"

tools: tool.n run.n

tool.n: tools/tool.hxml tools/CLI.hx
	@echo "Compiling tool.n"
	@cd tools && haxe tool.hxml

run.n: tools/run.hxml tools/Run.hx
	@echo "Compiling run.n"
	@cd tools && haxe run.hxml

template.zip:
	@echo "Generating template.zip"
	@cd template && zip -rqX ../template.zip . -x *.DS_Store*

haxepunk.zip: docs tools template.zip
	@echo "Building haxelib project"
	@zip -q haxepunk.zip run.n tool.n haxelib.json README.md include.xml template.zip
	@zip -rq haxepunk.zip haxepunk backend assets doc/pages -x *.DS_Store*

haxelib: haxepunk.zip
	@haxelib local haxepunk.zip > log.txt || cat log.txt

test: unit

unit:
	@echo "Running unit tests"
	@cd tests && haxelib run munit test test-${TEST}.hxml

checkstyle:
	haxelib run checkstyle -c checkstyle.json -s haxepunk

examples: tool.n
	@(for path in `find examples -name "*.hxml"`; \
		do echo "Building" $$path"..."; \
		(cd $$(dirname $$path); haxe $$(basename $$path)) || exit; \
		done)

clean:
	@echo "Cleaning up old files"
	@rm -f tool.n haxepunk.zip template.zip doc/xmls/*.xml
	@rm -rf doc/pages/*
