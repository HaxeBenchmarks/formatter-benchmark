#!/bin/bash

readonly SRC_FOLDER=../src

# preformat SRC_FOLDER
./out/cpp/Cli -s $SRC_FOLDER > /dev/null 2>&1

./out/cpp/Cli -s $SRC_FOLDER
node out/formatter.js -s $SRC_FOLDER
java -jar out/java/Cli.jar -s $SRC_FOLDER
java -jar out/jvm/Cli.jar -s $SRC_FOLDER
hl out/formatter.hl -s $SRC_FOLDER
neko out/formatter.n -s $SRC_FOLDER
php out/php/index.php -s $SRC_FOLDER
python3 out/formatter.py -s $SRC_FOLDER
mono out/cs/bin/Cli.exe -s $SRC_FOLDER
lua out/formatter.lua -s $SRC_FOLDER
