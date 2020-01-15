#!/bin/sh

if haxe docs.hxml; then

haxelib run dox -i xml -o pages/ \
    --include "haxepunk" \
    --exclude "haxepunk.backend" \
    --title "HaxePunk" \
    -D source-path "https://github.com/HaxePunk/HaxePunk/tree/master"

fi
