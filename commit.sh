#!/bin/sh
git add -f extra password-pasture sshyp-mfa LICENSE README.md version commit.sh .gitignore
git commit -m "$1"
git push
