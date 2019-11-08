#!/bin/bash

for folder in versions/*; do (cd $folder; ./run.sh); done
