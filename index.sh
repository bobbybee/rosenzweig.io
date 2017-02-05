#!/bin/sh

rm blog/index.md
find blog/*.md -exec ./sredate.sh {} \;

cat blog-list.md > blog/index.md
ls -1 --sort=time blog/*.md | sed -e s-blog/index.md-- | xargs -n 1 ./meta.sh >> blog/index.md

echo '<style>' > /tmp/open && echo '</style>' > /tmp/close
pandoc -f markdown -t html blog/index.md --standalone --self-contained -H /tmp/open -H global.css -H blog.css -H /tmp/close > blog/index.html
