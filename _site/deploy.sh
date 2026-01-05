#!/usr/bin/env bash
set -euo pipefail

MAIN_BRANCH="main"      # change if your main branch is called something else
DEPLOY_BRANCH="gh-pages"
BUILD_DIR="_site"

# Remember where we started
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# 1. Go to main and build
git checkout "$MAIN_BRANCH"
bundle exec jekyll build

# 2. Copy built site to a temp dir (outside git’s control)
TEMP_DIR="$(mktemp -d)"
cp -R "$BUILD_DIR"/. "$TEMP_DIR"

# 3. Switch to gh-pages and replace contents
git checkout "$DEPLOY_BRANCH" || git checkout --orphan "$DEPLOY_BRANCH"

rm -rf ./*
cp -R "$TEMP_DIR"/. .

# Optional: ensure GitHub doesn’t try to run Jekyll on this branch
touch .nojekyll

git add .

# 4. Commit and push if there are changes
if git diff --cached --quiet; then
  echo "No changes to deploy."
else
  git commit -m "Deploy $(date -u +'%Y-%m-%d %H:%M:%S UTC')"
  git push origin "$DEPLOY_BRANCH"
fi

# 5. Go back to where you were
git checkout "$CURRENT_BRANCH"

# Cleanup
rm -rf "$TEMP_DIR"
