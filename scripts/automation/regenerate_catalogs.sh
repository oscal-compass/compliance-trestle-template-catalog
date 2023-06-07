#!/bin/bash

source config.env

echo "Regenerating ${CATALOG}" 
trestle author catalog-generate --name $CATALOG --output md_catalogs/$CATALOG
