#!/bin/bash

OPTIONS="--conservative-collapse --collapse-boolean-attributes --collapse-inline-tag-whitespace --collapse-whitespace --decode-entities --html5 --minify-css 1 --remove-attribute-quotes --remove-comments --remove-empty-attributes --remove-empty-elements --remove-optional-tags --remove-redundant-attributes --remove-tag-whitespace --use-short-doctype"

STYLE=$(cat global.css)
awk -v STYLE="$STYLE" '{gsub(/\$\$STYLE\$\$/, STYLE); print}' < $1 > $1.mi
html-minifier $OPTIONS $1.mi > $1.min
#rm $1.mi
./upload.sh $1.min $1
