#!/bin/bash

set -e

find . -type f -path '*chapter*' -name '*.yml' | while read path; do

  dir=$(dirname "$path")
  file=$(basename "$path" .yml)
  new_path="$dir/$file.md"

  echo "Templating $path to $new_path"
  handlebars-cli "$(cat $path | yq -o json)" ./quiz-page.hb > $new_path

done
