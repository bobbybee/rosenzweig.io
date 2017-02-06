#!/bin/sh

rm blog/index.md
find blog/*.md -exec ./redate.sh {} \;

cat blog-list.md > blog/index.md
ls -1 --sort=time blog/*.md | sed -e s-blog/index.md-- | xargs -n 1 ./meta.sh >> blog/index.md
