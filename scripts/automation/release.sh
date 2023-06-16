#!/bin/bash

source config.env

version_tag=$(semantic-release print-version)
echo "Bumping version of catalogs to ${version_tag}" 
export VERSION_TAG="$version_tag"
echo "VERSION_TAG=${VERSION_TAG}" >> $GITHUB_ENV

COUNT=$(ls -l md_catalogs | grep ^- | wc -l)
if [ $COUNT -lt 1 ]
then
	./scripts/automation/regenerate_catalogs.sh $version_tag
fi

./scripts/automation/assemble_catalogs.sh $version_tag
git config --global user.email "$EMAIL"
git config --global user.name "$ENAME" 
semantic-release publish
