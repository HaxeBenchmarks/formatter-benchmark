#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"
ln -sfn ../../build 
ln -sfn ../../haxe_libraries/ haxe_libraries
ln -sfn ../../buildAll.hxml .
ln -sfn ../../src
lix download haxe nightly
lix use haxe nightly
lix download
