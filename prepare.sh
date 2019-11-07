#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"
git checkout -- .
git pull

git clone https://github.com/HaxeCheckstyle/haxe-formatter.git --depth 1
cp haxe-formatter/haxelib.json .
rm -rf haxe-formatter

for folder in data/*; do (cd $folder; git checkout -- .; git pull); done

for folder in versions/*; do (cd $folder; ./prepare.sh); done
