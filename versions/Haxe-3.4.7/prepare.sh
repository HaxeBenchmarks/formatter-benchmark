#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"
ln -sfn ../../build 
ln -sfn ../../haxe3_libraries/ haxe_libraries
ln -sfn ../../buildAll.hxml .
ln -sfn ../../src
lix download
