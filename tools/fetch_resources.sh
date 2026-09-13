#!/bin/bash

cd "$(dirname "$0")"
source build.conf
cd ..

./tools/clean.sh

mkdir "$SCRIPT_DST"

mkdir "$SCRIPT_DST/boot"
cp -r "$SCRIPT_PATH/boot/bootfile_autopilot_system.ks" "$SCRIPT_DST/boot/bootfile_autopilot_system.ks"

cp -r "$SCRIPT_PATH/autopilot_systems" "$SCRIPT_DST/autopilot_systems"