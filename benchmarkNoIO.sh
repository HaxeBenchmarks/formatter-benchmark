#!/bin/bash

source benchmark.env

readonly DATA=$*

function resetGit {
    for i in $( ls data ) ; do (cd data/$i; git checkout -- .); done;
}

resetGit
./out/cpp/NoIOMain $DATA
resetGit
node out/formatter.js $DATA
resetGit
node out/formatter.es6.js $DATA
resetGit
java -jar out/java/NoIOMain.jar $DATA
resetGit
java -jar out/jvm/NoIOMain.jar $DATA
resetGit
hl out/formatter.hl $DATA
resetGit
./out/hl/formatterCLI $DATA
resetGit
mono out/cs/bin/NoIOMain.exe $DATA
resetGit
haxe build/common.hxml --run NoIOMain $DATA
resetGit
php out/php/index.php $DATA
resetGit
neko out/formatter.n $DATA
resetGit
python3 out/formatter.py $DATA
# resetGit
# lua out/formatter.lua $DATA
