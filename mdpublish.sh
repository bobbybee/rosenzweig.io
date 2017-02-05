#!/bin/sh
cat $1 | sed -e 's|.html|.md|g' > $1.mi
./upload.sh $1.mi $1
