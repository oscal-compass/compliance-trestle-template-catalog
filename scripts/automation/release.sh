#!/bin/bash
set -eo pipefail

source config.env

COUNT_CATALOGS=$(ls -1 catalogs | wc -l)
COUNT_CATALOG_MD=$(ls -1 md_catalogs | wc -l)
if [ "$COUNT_CATALOGS" == "0" ] || [ "$COUNT_CATALOG_MD" == "0" ]
then
    echo "no catalog or markdown present -> nothing to do"
else
	next_version=$(semantic-release version --print 2>/dev/null || true)
	last_version=$(semantic-release version --print-last-released 2>/dev/null || true)
	# Match v7: empty VERSION_TAG when nothing to release.
	# Untagged repos: PSR prints 0.0.0 with no bump commits — skip that stamp.
	if [ "$next_version" = "$last_version" ] || { [ -z "$last_version" ] && [ "$next_version" = "0.0.0" ]; }; then
		version_tag=""
	else
		version_tag="$next_version"
	fi
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
	# --no-push/--no-vcs-release: push.sh commits catalog updates and moves the tag.
	if [ -n "$version_tag" ]; then
		semantic-release version --no-push --no-vcs-release
	fi
fi
