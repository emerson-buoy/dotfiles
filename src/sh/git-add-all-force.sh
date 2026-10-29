#!/bin/bash

BRANCH_NAME=$(git branch --show-current)

if [ "$BRANCH_NAME" = "main" ]; then
    printf "Main. STOP. \n\n\n"
    exit
fi

if [ "$BRANCH_NAME" = "master" ]; then
    printf "Master. STOP. \n\n\n"
    exit
fi

printf "[OK] Branch is not in ['main', 'master'].\n\n"
printf "I am going to do the following:\n\n"
printf "* git add .\n"
printf "* git commit --no-verify --amend --no-edit\n"
printf "* git push -f -u origin $BRANCH_NAME\n"
printf "* git status\n\n"

echo "Current diff:"
git diff --name-only
git add .

# In a monorepo subfolder, also pick up the lockfile at the root
REPO_ROOT=$(git rev-parse --show-toplevel)
for lock in yarn.lock pnpm-lock.yaml package-lock.json; do
    if [ -f "$REPO_ROOT/$lock" ]; then
        git add "$REPO_ROOT/$lock"
    fi
done

git commit --no-verify --amend --no-edit
git push -f -u origin "$BRANCH_NAME"
git status
