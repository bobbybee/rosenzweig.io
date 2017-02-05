#!/bin/sh
rm blog/index.md
find blog/*.md -exec touch -d `head -n 3 {} | tail -n 1 | sed -e 's|_||g'` {} \;
