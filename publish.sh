#!/bin/bash

FILE=${1%.md}

if [[ $FILE == *presentation ]]
then
    STYLE="--css present.css --section-divs"
elif [[ $FILE == blog/* ]]
then
    STYLE="--css global.css --css blog.css"
else
    STYLE="--css global.css"
fi

pandoc -f markdown+smart -t html $FILE.md --standalone --self-contained $STYLE > $FILE.html

html-minifier --conservative-collapse --collapse-boolean-attributes --collapse-inline-tag-whitespace --collapse-whitespace --decode-entities --html5 --minify-css 1 --remove-attribute-quotes --remove-comments --remove-empty-attributes --remove-empty-elements --remove-optional-tags --remove-redundant-attributes --remove-tag-whitespace --use-short-doctype $FILE.html > $FILE.min
./upload.sh $FILE.min $FILE.html

sed $FILE.md -e 's|.html|.md|g' > $FILE.min
./upload.sh $FILE.min $FILE.md
