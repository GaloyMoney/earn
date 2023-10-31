#!/bin/bash

set -e

find . -type f -path '*chapter*' -name '*.yml' | while read path; do

  dir=$(dirname "$path")
  file=$(basename "$path" .yml)
  new_path="$dir/$file.json"

  echo "Templating $path to $new_path"
  echo "$(cat $path | yq -o json | jq '{ (.screen): {screen: .screen, answers: [.answers[].answer], feedback: [.answers[].feedback], question: .question, text: .text, title: .title} }')" > $new_path

done

find . -type d -path '*chapter*' | sort | while read dirname; do

  dir=$(dirname "$dirname")
  chapter=$(echo $dirname | cut -d'-' -f 2)

  new_file="$dirname/$chapter-combined.json"

  echo "Combining chapter $chapter to $new_file"

  chapterfiles=$(find $dirname -type f -name '*.json' -not -name '*-combined.json' | sort)
  chaptermeta=$(find $dirname -type f -name 'README.md')
  chaptertitle=$(head -n 1 $chaptermeta | sed 's/#//g' | sed 's/Chapter [0-9][0-9][0-9] - //' | xargs)

  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    chapterid=$(echo $chaptertitle | sed -e "s/\b\(.\)/\u\1/g" | sed "s/[^[:alpha:]]//g" | sed 's/ //g')
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    chapterid=$(echo $chaptertitle | gsed -e "s/\b\(.\)/\u\1/g" | sed "s/[^[:alpha:]]//g" | sed 's/ //g')
  fi

  jq -n '[ inputs[] | { (.screen|tostring): del(.screen) }]' $chapterfiles | jq --arg chaptertitle "$chaptertitle" --arg chapterid "$chapterid" '{ ($chapterid): { title: $chaptertitle, questions: (. |= add) } }' > $new_file
done

allchapterfiles=$(find . -type f -name '*-combined.json' | sort)
combinedfile="./combined-output.json"

jq -s add $allchapterfiles > $combinedfile
rm -f $allchapterfiles
