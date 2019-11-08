#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"
git checkout -- .
git pull

for folder in data/*; do (cd $folder; git checkout -- .; git pull); done

for folder in versions/*; do (cd $folder; ./prepare.sh); done
