#!/bin/sh

echo '<style>' > /tmp/open && echo '</style>'> /tmp/close

./index-posts.sh
pandoc -f markdown -t html blog-index.md.tmp --standalone --self-contained -H /tmp/open -H global.css -H /tmp/close > blog/index.html
