#! /bin/sh

echo "convert file:$1"
convert "$1"  -background none -gravity center -resize 400x250 -extent 400x250 "$1"
