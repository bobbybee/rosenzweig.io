#!/bin/sh
DATE=$(head -n 3 $1 | tail -n 1 | sed -e 's|_||g') 
echo $DATE
touch -d "$DATE" $1
