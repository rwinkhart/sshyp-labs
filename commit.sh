#!/bin/sh
git add -f LICENSE README.md commit.sh extensions extra pointers .gitignore 
git commit -m "$1"
git push
