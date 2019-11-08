#!/bin/bash

./benchmark.sh -s data/haxe/std -s data/openfl/src -s data/lime/src | tee results.csv
haxe buildConvertCsv.hxml
