#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"

./prepare.sh
./build.sh
./run.sh