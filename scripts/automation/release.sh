#!/bin/bash

source config.env

COUNT_CATALOGS=$(ls -1 catalogs | wc -l)
COUNT_CATALOG_MD=$(ls -1 md_catalogs | wc -l)
if [ "$COUNT_CATALOGS" == "0" ] || [ "$COUNT_CATALOG_MD" == "0" ]
then
    echo "no catalog or markdown present -> nothing to do"
else
    version_tag=$(semantic-release print-version)
	echo "Bumping version of catalogs to ${version_tag}" 
	export VERSION_TAG="$version_tag"
	echo "VERSION_TAG=${VERSION_TAG}" >> $GITHUB_ENV
	# There is no md but json has at least one control
	COUNT=$(ls -1 md_catalogs | wc -l)
	if [ $COUNT -lt 1 ]
	then
		./scripts/automation/regenerate_catalogs.sh 
	fi
	./scripts/automation/assemble_catalogs.sh $version_tag
	git config --global user.email "$EMAIL"
	git config --global user.name "$NAME" 
	semantic-release publish
fi
