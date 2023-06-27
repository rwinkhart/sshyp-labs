#!/bin/sh
git add -f LICENSE README.md commit.sh extensions extra pointers 
git commit -m "$1"
git push
