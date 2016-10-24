#!/bin/bash

html-minifier $1 -o $1.min
scp $1.min alyssa@rosenzweig.io:/var/www/html/$1
