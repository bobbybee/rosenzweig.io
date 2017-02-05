#!/bin/sh
touch -d "$(head -n 3 $1 | tail -n 1 | sed -e 's|_||g')" $1
