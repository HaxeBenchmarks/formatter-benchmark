#!/bin/bash

for folder in versions/*; do (cd $folder; ./build.sh); done
