#!/bin/bash

readonly DATA=$*

function resetGit {
    for i in $( ls data ) ; do (cd data/$i; git checkout -- .); done;
}

./out/cpp/Cli $DATA
resetGit
node out/formatter.js $DATA
resetGit
java -jar out/java/Cli.jar $DATA
resetGit
java -jar out/jvm/Cli.jar $DATA
resetGit
# $HL_BINARY out/formatter.hl $DATA
# resetGit
neko out/formatter.n $DATA
resetGit
php out/php/index.php $DATA
resetGit
python3 out/formatter.py $DATA
# resetGit
# mono out/cs/bin/Cli.exe $DATA
# resetGit
# lua out/formatter.lua $DATA
