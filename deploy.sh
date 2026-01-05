#!/usr/bin/env bash
set -euo pipefail

MAIN_BRANCH="main"
DEPLOY_BRANCH="gh-pages"
BUILD_DIR="_site"

# Remember where we started
START_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# 1. Go to main and build
git checkout "$MAIN_BRANCH"
bundle exec jekyll build

# 2. Copy built site to a temp dir (outside git’s control)
TEMP_DIR="$(mktemp -d)"
cp -R "$BUILD_DIR"/. "$TEMP_DIR"/

# 3. Switch to gh-pages (or create it)
if git show-ref --quiet "refs/heads/$DEPLOY_BRANCH"; then
  git checkout "$DEPLOY_BRANCH"
else
  git checkout --orphan "$DEPLOY_BRANCH"
fi

# 4. Nuke gh-pages contents ONLY
rm -rf ./*

# 5. Copy new site in
cp -R "$TEMP_DIR"/. .

# Make sure GitHub doesn't try to run Jekyll here
touch .nojekyll

git add .

if git diff --cached --quiet; then
  echo "No changes to deploy."
else
  git commit -m "Deploy $(date -u +'%Y-%m-%d %H:%M:%S UTC')"
  git push origin "$DEPLOY_BRANCH"
fi

# 6. Go back to where you were
git checkout "$START_BRANCH"

rm -rf "$TEMP_DIR"
