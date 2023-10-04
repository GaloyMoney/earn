#!/bin/bash

set -e

find . -type f -path '*chapter*' -name '*.yml' | while read path; do

  dir=$(dirname "$path")
  file=$(basename "$path" .yml)
  new_path="$dir/$file.json"

  echo "Templating $path to $new_path"
  echo "$(cat $path | yq -o json | jq '{answers: [.answers[].answer], feedback: [.answers[].feedback], id: .screen, question: .question, text: .text, title: .title, type: "Text"}')" > $new_path

done

find . -type d -path '*chapter*' | sort | while read dirname; do

  dir=$(dirname "$dirname")
  chapter=$(echo $dirname | cut -d'-' -f 2)

  new_file="$dirname/$chapter-combined.json"

  echo "Combining chapter $chapter to $new_file"

  chapterfiles=$(find $dirname -type f -name '*.json' | sort)
  chaptermeta=$(find $dirname -type f -name 'README.md')
  chaptertitle=$(head -n 1 $chaptermeta | sed 's/#//g' | sed 's/Chapter [0-9][0-9][0-9] - //' | xargs)
  chapterid=$(echo $chaptertitle | sed 's/ //g')

  jq --arg chaptertitle "$chaptertitle" --arg chapterid "$chapterid" -s '{content: map(.), meta: {id: $chapterid, title: $chaptertitle }}' $chapterfiles > $new_file

done
