#!/bin/bash

OPTIONS="--conservative-collapse --collapse-boolean-attributes --collapse-inline-tag-whitespace --collapse-whitespace --decode-entities --html5 --minify-css 1 --remove-attribute-quotes --remove-comments --remove-empty-attributes --remove-empty-elements --remove-optional-tags --remove-redundant-attributes --remove-tag-whitespace --use-short-doctype"

html-minifier $OPTIONS $1 > $1.min
./upload.sh $1.min $1
