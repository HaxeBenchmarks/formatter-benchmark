#!/bin/bash

readonly VER=`haxe -version`
echo "Running Haxe $VER benchmark"
./benchmark.sh -s data/haxe/std -s data/openfl/src -s data/lime/src | tee results.csv
haxe buildConvertCsv.hxml
