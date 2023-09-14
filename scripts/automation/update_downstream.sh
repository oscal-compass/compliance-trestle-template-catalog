#!/bin/bash

source config.env

export COMMIT_TITLE="chore: Catalogs automatic update."
export COMMIT_BODY="Sync catalogs with $CATALOG repo"
git config --global user.email "$EMAIL"
git config --global user.name "$NAME"
cd "$REPO_PROFILE"
git checkout -b "catalogs_autoupdate_$GITHUB_RUN_ID"
cp -r ../catalogs .
if [ -z "$(git status --porcelain)" ]; then 
  echo "Nothing to commit"
else
  git add catalogs
  if [ -z "$(git status --untracked-files=no --porcelain)" ]; then 
     echo "Nothing to commit"
  else
     git commit --message "$COMMIT_TITLE"
     remote=$URL_PROFILE
     git push -u "$remote" "catalogs_autoupdate_$GITHUB_RUN_ID"
     echo $COMMIT_BODY
     gh pr create -t "$COMMIT_TITLE" -b "$COMMIT_BODY" -B "develop" -H "catalogs_autoupdate_$GITHUB_RUN_ID" 
  fi
fi
