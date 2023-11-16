#!/bin/bash

source config.env

# If there is no catalog or markdown, then there is nothing to do
COUNT_CATALOG_MD=$(ls -l md_catalogs | grep ^- | wc -l)
COUNT_CATALOGS=$(ls -l catalogs | grep ^- | wc -l)
let "INITIALIZED = $COUNT_CATALOG_MD + $COUNT_CATALOGS"
if [ $INITIALIZED -eq 0 ]
then
	echo "release: no catalog or markdown, nothing to do"
	exit 0
fi

version_tag=$(semantic-release print-version)
echo "Bumping version of catalogs to ${version_tag}" 
export VERSION_TAG="$version_tag"
echo "VERSION_TAG=${VERSION_TAG}" >> $GITHUB_ENV

# There is no md but json has at least one control
COUNT=$(ls -l md_catalogs | grep ^- | wc -l)
if [ $COUNT -lt 1 ]
then
	./scripts/automation/regenerate_catalogs.sh 
fi

./scripts/automation/assemble_catalogs.sh $version_tag
git config --global user.email "$EMAIL"
git config --global user.name "$NAME" 
semantic-release publish
