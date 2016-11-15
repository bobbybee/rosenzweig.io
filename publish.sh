#!/bin/bash

html-minifier --collapse-boolean-attributes --colapse-inline-tag-whitespace --collapse-whitespace --html5 --minify-css 1 --remove-attribute-quotes --remove-comments --remove-empty-attributes --remove-empty-elements --remove-optional-elements --remove-redundant-attributes --remove-tag-whitespace $1 -o $1.min
scp $1.min alyssa@rosenzweig.io:/var/www/html/$1
