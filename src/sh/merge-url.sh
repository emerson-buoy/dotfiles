#!/bin/bash
# usage: git push 2>&1 | merge-url.sh   or   merge-url.sh "<text>"

input="${*:-$(cat)}"
url=$(echo "$input" | grep -o 'https://[^[:space:]]*')

# Print the extracted URL
echo "$url"
