#!/bin/bash

FILE=${1%.md}

echo "<style>" > /tmp/open && echo "</style>" > /tmp/close

if [[ $FILE == *presentation ]]
then
    STYLE="-H present.css --section-divs"
elif [[ $FILE == blog/* ]]
then
    STYLE="-H global.css -H blog.css"
else
    STYLE="-H global.css"
fi

pandoc -f markdown -t html $FILE.md --smart --standalone --self-contained -H /tmp/open $STYLE -H /tmp/close > $FILE.html

html-minifier --conservative-collapse --collapse-boolean-attributes --collapse-inline-tag-whitespace --collapse-whitespace --decode-entities --html5 --minify-css 1 --remove-attribute-quotes --remove-comments --remove-empty-attributes --remove-empty-elements --remove-optional-tags --remove-redundant-attributes --remove-tag-whitespace --use-short-doctype $FILE.html > $FILE.min
./upload.sh $FILE.min $FILE.html

sed $FILE.md -e 's|.html|.md|g' > $FILE.min
./upload.sh $FILE.min $FILE.md
