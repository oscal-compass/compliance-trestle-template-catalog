#!/bin/bash

source config.env

RESULT=$(ls catalogs)

if [[ "$RESULT" == *"$CATALOG"* ]]; then
  echo "catalog exists, exit 1";
  exit 1;
else
  echo "catalog does not exist, exit 0"
  exit 0;
fi
