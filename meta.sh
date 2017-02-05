#!/bin/sh

HTML=$(echo ${1%.md}.html | sed -e s-blog/--)
TITLE=$(head -n 1 $1)
DATE=$(head -n 3 $1 | tail -n 1 | stripmd)
LEADER=$(head -n 5 $1 | tail -n 1 | stripmd)

echo "[$TITLE]($HTML)"
echo "*$DATE*"
echo ""
echo "$LEADER"
