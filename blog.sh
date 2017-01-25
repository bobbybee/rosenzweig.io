#!/bin/bash

HTML=${1%.md}.html
TITLE=`head -n 1 $1`

MID=$(pandoc -f markdown $1 | python -c 'import json,sys; print(json.dumps(sys.stdin.read()))')
VIEW="{\"header\": \"$TITLE\", \"content\": $MID}"

echo $VIEW | mustache - template.html $HTML
