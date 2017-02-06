#!/bin/bash

echo "<style>" > /tmp/open && echo "</style>" > /tmp/close
pandoc -f markdown -t html $1.md --standalone --srlf-contained -H /tmp/open -H global.css $([[$1 == blog*]] && echo "-H blog.css") -H /tmp/close > $1.html
html-minifier --conservative-collapse --collapse-boolean-attributes --collapse-inline-tag-whitespace --collapse-whitespace --decode-entities --html5 --minify-css 1 --remove-attribute-quotes --remove-comments --remove-empty-attributes --remove-empty-elements --remove-optional-tags --remove-redundant-attributes --remove-tag-whitespace --use-short-doctype $1.html > $1.min
./upload.sh $1.min $1.html

sed $1.md -e 's|.html|.md|g' > $1.min
./upload.sh $1.min $1.md
