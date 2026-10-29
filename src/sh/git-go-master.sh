#!/bin/bash

clear

if git rev-parse --verify -q master >/dev/null; then
    git checkout master
else
    printf "\n'master' branch not found. Checking out 'main'.\n\n"
    git checkout main
fi

git pull
git status
