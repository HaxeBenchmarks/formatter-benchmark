#!/bin/bash

for folder in versions/*; do (cd $folder; haxe buildAll.hxml); done
