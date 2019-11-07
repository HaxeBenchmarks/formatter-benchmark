#!/bin/bash -e

export HASHLINK_CC_PARAMS="-m32 -I hashlink/src"
haxe buildAll.hxml
