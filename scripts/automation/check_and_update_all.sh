#!/bin/bash

CHANGES=`git diff-tree --no-commit-id --name-only -r HEAD`

md_changed=false
json_changed=false

# bash regex does not support lazy match, so need to use two patterns to match before and after the control id
md1=$"^md_catalogs/"
md2=$"\.md$"

json1=$"^catalogs/"
json2=$"\.json$"

for val in ${CHANGES[@]} ; do
  if [[ $val =~ $md1 && $val =~ $md2 ]]; then
    md_changed=true
  fi

  if [[ $val =~ $json1 && $val =~ $json2 ]]; then
    json_changed=true
  fi
done

echo "md_changed = $md_changed, json_changed = $json_changed"

if [[ $json_changed = true ]]; then
    echo "Json file(s) were changed, regenerating markdowns..."
    ./scripts/automation/regenerate_catalogs.sh
fi


if [[ $md_changed = true ]]; then
    echo "Md file(s) were changed, assembling catalog..."
    ./scripts/automation/assemble_catalogs.sh
fi
