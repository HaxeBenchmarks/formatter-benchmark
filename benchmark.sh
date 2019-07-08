#!/bin/bash

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

readonly DATA=$*

function resetGit {
    for i in $( ls data ) ; do (cd data/$i; git checkout -- .); done;
}

./out/cpp/Cli $DATA
resetGit
node out/formatter.js $DATA
resetGit
node out/formatter.es6.js $DATA
resetGit
java -jar out/java/Cli.jar $DATA
resetGit
java -jar out/jvm/Cli.jar $DATA
resetGit
/usr/local/bin/hl out/formatter.hl $DATA
resetGit
mono out/cs/bin/Cli.exe $DATA
resetGit
php out/php/index.php $DATA
resetGit
neko out/formatter.n $DATA
resetGit
python3 out/formatter.py $DATA
# resetGit
# lua out/formatter.lua $DATA
