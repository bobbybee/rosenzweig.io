#!/bin/sh

./index-json.sh | mustache - blog-list.html blog/index.html
