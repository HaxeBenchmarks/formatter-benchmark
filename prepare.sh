#!/bin/bash

# does not restart itself if there is a change in prepare.sh!
echo "Update benchmark"
cd "$( dirname "${BASH_SOURCE[0]}" )"
git checkout -- .
git pull

mkdir -p results/Haxe-3.4.7
mkdir -p results/Haxe-4.0.1
mkdir -p results/Haxe-nightly

echo "Download / update test data (Haxe stdlib, OpenFl and Lime sources)"
for folder in data/*; do (cd $folder; git checkout -- .; git pull); done

echo "Prepare different Haxe versions"
for folder in versions/*; do (cd $folder; ./prepare.sh); done
