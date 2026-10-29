#!/bin/bash
# Reinstalls node modules and CocoaPods for a React Native app.
# usage: reset-pods.sh [-r] [project-path]   (-r also removes Podfile.lock; path defaults to the current folder)
clear

REMOVE_LOCK=false
if [ "$1" = "-r" ]; then
    REMOVE_LOCK=true
    shift
fi

PROJECT_PATH="${1:-$PWD}"
PODS_PATH="$PROJECT_PATH/ios"

if [ ! -d "$PODS_PATH" ]; then
    printf "No ios folder in %s. Run it from the app folder or pass its path.\n" "$PROJECT_PATH"
    exit 1
fi

# Monorepos keep the lockfile at the git root
REPO_ROOT=$(git -C "$PROJECT_PATH" rev-parse --show-toplevel 2>/dev/null || echo "$PROJECT_PATH")
if [ -f "$REPO_ROOT/pnpm-lock.yaml" ]; then
    INSTALL="pnpm install"
elif [ -f "$REPO_ROOT/yarn.lock" ]; then
    INSTALL="yarn"
else
    INSTALL="npm install"
fi

printf "\n\nI am going to do the following:\n\n"
printf "* cd %s\n" "$PROJECT_PATH"
printf "* rm -rf node_modules\n"
printf "* %s\n" "$INSTALL"
printf "* cd %s\n" "$PODS_PATH"
if $REMOVE_LOCK; then
    printf "* remove Podfile.lock\n"
fi
printf "* rm -rf Pods\n"
printf "* pod install\n"
printf "* cd %s\n" "$PROJECT_PATH"
printf "* git status \n\n"

cd "$PROJECT_PATH" || exit 1
printf "\nRemoving modules... %s/node_modules\n" "$PROJECT_PATH"
rm -rf "$PROJECT_PATH/node_modules"
printf "\nDone\n\n"
printf "\nReinstall modules...\n\n"
$INSTALL
printf "\nDone\n\n"

cd "$PODS_PATH" || exit 1
rm -rf "$PODS_PATH/Pods"
if $REMOVE_LOCK; then
    rm -f "$PODS_PATH/Podfile.lock"
fi
pod install
ls -las

cd "$PROJECT_PATH" || exit 1
git status
