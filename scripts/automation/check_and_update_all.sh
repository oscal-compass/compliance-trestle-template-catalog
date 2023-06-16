#!/bin/bash

CHANGES=`git diff-tree --no-commit-id --name-only -r HEAD`

md_changed=false
json_changed=false
xlsx_changed=false

# bash regex does not support lazy match, so need to use two patterns to match before and after the control id
md1=$"^md_catalogs/"
md2=$"\.md$"

json1=$"^catalogs/"
json2=$"\.json$"

xlsx1=$"^data/"
xlsx2=$"\.xlsx$"

for val in ${CHANGES[@]} ; do
  if [[ $val =~ $md1 && $val =~ $md2 ]]; then
    md_changed=true
  fi

  if [[ $val =~ $json1 && $val =~ $json2 ]]; then
    json_changed=true
  fi

  if [[ $val =~ $xlsx1 && $val =~ $xlsx2 ]]; then
    xlsx_changed=true
  fi
done

if [[ $xlsx_changed = true ]]; then
    echo "Xlsx file(s) were changed, generating catalog JSON and regenerating markdowns..."
    python scripts/fs_cloud_create_oscal_catalog.py --input data/IBM_Cloud_Framework_for_Financial_Services_-_Control_Requirements_v1.1.0.xlsx --sheet "Control Requirements" --output catalogs/IBM_FS_CLOUD_ONLY --catalog catalogs/NIST_800-53_rev4/catalog.json
    ./scripts/automation/regenerate_catalogs.sh
fi

if [[ $json_changed = true ]]; then
    echo "Json file(s) were changed, regenerating markdowns..."
    ./scripts/automation/regenerate_catalogs.sh
fi


if [[ $md_changed = true ]]; then
    echo "Md file(s) were changed, assembling catalog..."
    ./scripts/automation/assemble_catalogs.sh
fi



echo "$md_changed $json_changed $xlsx_changed"
