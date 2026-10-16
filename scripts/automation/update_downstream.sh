#!/bin/bash
# Sync assembled catalogs into the downstream profile repo.
#
# Downstream PR behavior (fixed branch catalogs_autoupdate → develop):
# - If an open PR already exists for that branch, append the new commit and
#   push so changes are bundled into the existing PR (avoids duplicate PRs /
#   merge conflicts from per-run branches).
# - If no open PR exists, reset the branch from develop, force-push with
#   lease, and open a new PR.
set -eo pipefail

source config.env

export COMMIT_TITLE="chore: Catalogs automatic update."
export COMMIT_BODY="Sync catalogs with $CATALOG repo"
BRANCH="catalogs_autoupdate"

git config --global user.email "$EMAIL"
git config --global user.name "$NAME"
cd "$REPO_PROFILE"

git fetch origin
# Capture PR state once to avoid a race between checkout and push decisions.
open_pr=$(gh pr list -H "$BRANCH" -B develop --state open --json number -q '.[0].number')
# Reuse the open PR's branch tip when one exists; otherwise start from develop
# so a leftover branch after merge does not carry stale commits forward.
if [ -n "$open_pr" ]; then
  git checkout -B "$BRANCH" "origin/$BRANCH"
else
  # No open PR: start fresh from develop (replaces a stale post-merge branch).
  git checkout -B "$BRANCH" origin/develop
fi

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
     if [ -n "$open_pr" ]; then
       # Bundle: push onto the existing open PR.
       git push -u "$remote" "$BRANCH"
       echo "Updated existing open PR on $BRANCH"
     else
       # No open PR: publish a fresh branch and open a new PR.
       git push -u --force-with-lease "$remote" "$BRANCH"
       echo "$COMMIT_BODY"
       gh pr create -t "$COMMIT_TITLE" -b "$COMMIT_BODY" -B "develop" -H "$BRANCH"
     fi
  fi
fi
