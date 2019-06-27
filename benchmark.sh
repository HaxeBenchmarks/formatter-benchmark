#!/bin/bash

readonly DATA=$*

# preformat SRC_FOLDER
./out/cpp/Cli $DATA > /dev/null 2>&1

./out/cpp/Cli $DATA
node out/formatter.js $DATA
java -jar out/java/Cli.jar $DATA
java -jar out/jvm/Cli.jar $DATA
# $HL_BINARY out/formatter.hl $DATA
neko out/formatter.n $DATA
php out/php/index.php $DATA
python3 out/formatter.py $DATA
mono out/cs/bin/Cli.exe $DATA
lua out/formatter.lua $DATA
