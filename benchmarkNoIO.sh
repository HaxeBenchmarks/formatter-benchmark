#!/bin/bash

source benchmark.env

./out/cpp/NoIOMain
./out/cppGCGen/NoIOMain
node out/formatter.js
node out/formatter.es6.js
java -jar out/java/NoIOMain.jar
java -jar out/jvm/NoIOMain.jar
hl out/formatter.hl
./out/hl/formatterCLI
mono out/cs/bin/NoIOMain.exe
haxe build/commonNoIO.hxml --run NoIOMain
php out/php/index.php
neko out/formatter.n
python3 out/formatter.py
# 
# lua out/formatter.lua

# second run to smooth graphs a little
./out/cpp/NoIOMain
./out/cppGCGen/NoIOMain
node out/formatter.js
node out/formatter.es6.js
java -jar out/java/NoIOMain.jar
java -jar out/jvm/NoIOMain.jar
hl out/formatter.hl
./out/hl/formatterCLI
