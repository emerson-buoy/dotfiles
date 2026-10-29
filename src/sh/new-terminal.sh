#!/bin/bash

COMMAND=$1

osascript -e 'on run argv' -e 'tell app "Terminal" to do script (item 1 of argv)' -e 'end run' "$COMMAND"
