#!/bin/bash

source config.env

version_tag=$1
if [ ${version_tag} != "" ]; then 
	echo "Assembling ${CATALOG} with version ${version_tag}"
	trestle author catalog-assemble --set-parameters --markdown md_catalogs/$CATALOG --output $CATALOG --version $version_tag 
else
	echo "Assembling ${CATALOG}"
	trestle author catalog-assemble --set-parameters --markdown md_catalogs/$CATALOG --output $CATALOG
fi
