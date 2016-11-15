#!/bin/bash

MID=${1%.md}.htm
HTML=${1%.md}.html
TITLE=`head -n 1 $1`

pandoc -f markdown $1 > $MID
cat template.html | sed -e "s/CONTENT/cat $MID/e" -e "s/HEADER/$TITLE/" > $HTML

./publish.sh $HTML
