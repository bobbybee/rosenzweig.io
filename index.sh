#!/bin/sh

./index-json.sh | mustache - blog-list.html listing.html
