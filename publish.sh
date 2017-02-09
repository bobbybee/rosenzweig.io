#!/bin/bash

FILE=${1%.md}
echo "<style>" > /tmp/open && echo "</style>" > /tmp/close
pandoc -f markdown -t html $FILE.md --standalone --self-contained -H /tmp/open -H global.css $([[ $FILE == blog* ]] && echo "-H blog.css") -H /tmp/close > $FILE.html
html-minifier --conservative-collapse --collapse-boolean-attributes --collapse-inline-tag-whitespace --collapse-whitespace --decode-entities --html5 --minify-css 1 --remove-attribute-quotes --remove-comments --remove-empty-attributes --remove-empty-elements --remove-optional-tags --remove-redundant-attributes --remove-tag-whitespace --use-short-doctype $FILE.html > $FILE.min
./upload.sh $FILE.min $FILE.html

sed $FILE.md -e 's|.html|.md|g' > $FILE.min
./upload.sh $FILE.min $FILE.md
