#!/bin/sh

HTML=$(echo ${1%.md}.html | sed -e s-blog/--)
TITLE=$(head -n 1 $1)
DATE=$(head -n 3 $1 | tail -n 1)
LEADER=$(head -n 5 $1 | tail -n 1 | sed -E -e 's/(\.|\?|\!)( |$).*/.../g')

echo "[$TITLE]($HTML){.title}"
echo "*$DATE*"
echo ""
echo "$LEADER"
echo ""
