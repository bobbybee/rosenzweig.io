#!/bin/sh

URL=$(echo ${1%.md}.html | sed -e s-blog/--)

echo "[$(sed -n 1p $1)]($URL){.title}"
echo "*$(sed -n 3p $1)*"
echo ""
sed -n 5p $1 | sed -E -e 's/(\.|\?|\!)( |$).*/.../g'
echo ""
