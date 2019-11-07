#!/bin/bash -e

cd "$( dirname "${BASH_SOURCE[0]}" )"
ln -sfn ../../benchmark.sh .
ln -sfn ../../build 
ln -sfn ../../buildAll.hxml .
ln -sfn ../../data
ln -sfn ../../haxe_libraries/ haxe_libraries
ln -sfn ../../haxelib.json .
ln -sfn ../../src
lix download haxe nightly
lix use haxe nightly
lix download
lix install gh:HaxeCheckstyle/haxe-formatter
lix install gh:HaxeCheckstyle/tokentree
lix install haxelib:hxcpp
