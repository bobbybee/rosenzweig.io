#!/bin/bash

MID=${1%.md}.htm
HTML=${1%.md}.html

pandoc -f markdown $1 > $MID
cat template.html | sed s/**CONTENT**/cat $MID/e > $HTML

#../publish.sh $HTML
