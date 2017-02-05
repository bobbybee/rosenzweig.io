#!/bin/sh
rm blog/index.md
find blog/*.md -exec ./sredate.sh {} \;
