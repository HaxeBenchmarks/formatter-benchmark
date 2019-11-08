#!/bin/bash


mv out/php out/phpOff # currently PHP7 formatter built with Haxe 3 "hangs" somewhere in Lime sources - needs investigation

./benchmark.sh -s data/haxe/std -s data/openfl/src -s data/lime/src | tee results.csv
haxe buildConvertCsv.hxml
