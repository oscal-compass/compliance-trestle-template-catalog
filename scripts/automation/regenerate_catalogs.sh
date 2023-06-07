#!/bin/bash

source config.env

echo "Regenerating ${catalog}" 
trestle author catalog-generate --name $catalog --output md_catalogs/$catalog
