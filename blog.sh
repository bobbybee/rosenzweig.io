#!/bin/bash

echo '<style>' > /tmp/open && echo '</style>'> /tmp/close
pandoc -f markdown -t html $1 --standalone --self-contained -H /tmp/open -H global.css -H /tmp/close > ${1%.md}.html
