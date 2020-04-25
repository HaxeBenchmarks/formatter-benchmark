#!/bin/bash

lix install github:HaxeFoundation/hxcpp
readonly HXCPP_FOLDER="$HOME/haxe/haxe_libraries`cat haxe_libraries/hxcpp.hxml  | grep -- ^-cp |cut -d\} -f2`"

cp .haxerc $HXCPP_FOLDER/project
mkdir $HXCPP_FOLDER/project/haxe_libraries
cp haxe_libraries/hxcpp.hxml $HXCPP_FOLDER/project/haxe_libraries

cd $HXCPP_FOLDER
rm -rf bin project/cppia_bin

cd project
echo "y" | haxe compile-cppia.hxml
