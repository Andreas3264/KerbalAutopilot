#!/bin/bash

cd "$(dirname "$0")"
source build.conf
cd ..

rm -rf $SCRIPT_DST