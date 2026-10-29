#!/bin/bash
INPUT="$@"

# Strip Linear URL prefix, keep everything after /issue/
if [[ "$INPUT" == *"linear.app"*"/issue/"* ]]; then
  INPUT="${INPUT##*/issue/}"
fi

BRANCH_NAME=$(~/scripts/src/js/dash-case.js $INPUT)

printf "\n=> Checking out new branch: '$BRANCH_NAME'\n\n"

git checkout -b $BRANCH_NAME
