#!/bin/bash

set -e

cd repo
make update-md-files

if [[ -z $(git config --global user.email) ]]; then
  git config --global user.email "bot@galoy.io"
fi
if [[ -z $(git config --global user.name) ]]; then
  git config --global user.name "CI Bot"
fi

git add -A
git status

git commit -m "chore: re-render markdown files"
