#!/bin/sh
find blog/*.md   -exec ./blog.sh    {}    \; 
find blog/*.html -exec ./publish.sh {}    \;
find blog/*.md   -exec ./upload.sh  {} {} \;
