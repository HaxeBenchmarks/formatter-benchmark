#!/bin/bash

source benchmark.env

readonly DATA=$*

function resetGit {
    for i in $( ls data ) ; do (cd data/$i; git checkout -- .); done;
}

resetGit
./out/cpp/Cli $DATA
resetGit
./out/cppGCGen/Cli $DATA
resetGit
node out/formatter.js $DATA
resetGit
node out/formatter.es6.js $DATA
resetGit
java -jar out/java/Cli.jar $DATA
resetGit
java -jar out/jvm/Cli.jar $DATA
resetGit
hl out/formatter.hl $DATA
resetGit
./out/hl/formatterCLI $DATA
resetGit
mono out/cs/bin/Cli.exe $DATA
resetGit
haxe build/common.hxml --run formatter.Cli $DATA
resetGit
php out/php/index.php $DATA
resetGit
neko out/formatter.n $DATA
resetGit
python3 out/formatter.py $DATA
# resetGit
# lua out/formatter.lua $DATA

# second run to smooth graphs a little
resetGit
./out/cpp/Cli $DATA
resetGit
./out/cppGCGen/Cli $DATA
resetGit
node out/formatter.js $DATA
resetGit
node out/formatter.es6.js $DATA
resetGit
java -jar out/java/Cli.jar $DATA
resetGit
java -jar out/jvm/Cli.jar $DATA
resetGit
hl out/formatter.hl $DATA
resetGit
./out/hl/formatterCLI $DATA
# resetGit
# lua out/formatter.lua $DATA
