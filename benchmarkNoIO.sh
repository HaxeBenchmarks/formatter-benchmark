#!/bin/bash

source benchmark.env

./out/cpp/NoIOMain
node out/formatter.js
node out/formatter.es6.js
java -jar out/java/NoIOMain.jar
java -jar out/jvm/NoIOMain.jar
hl out/formatter.hl
./out/hl/formatterCLI
mono out/cs/bin/NoIOMain.exe
haxe build/common.hxml --run NoIOMain
php out/php/index.php
neko out/formatter.n
python3 out/formatter.py
# 
# lua out/formatter.lua
