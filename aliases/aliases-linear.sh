# Needs LINEAR_PROJECT_NAME in ~/.dotfiles.env
alias linear='chrome "https://linear.app/$LINEAR_PROJECT_NAME/my-issues/assigned"'
alias lienar="linear"

# Branch like dev-24139-some-slug → https://linear.app/$LINEAR_PROJECT_NAME/issue/dev-24139
this_issue() {
  local branch="${1:-$(git rev-parse --abbrev-ref HEAD 2>/dev/null)}"
  if [[ -z "$branch" || "$branch" == "HEAD" ]]; then
    echo "this_issue: not on a named git branch" >&2
    return 1
  fi
  local rest="${branch#*-}"
  if [[ "$rest" == "$branch" ]]; then
    echo "this_issue: branch has no dash (expected prefix-number-...): $branch" >&2
    return 1
  fi
  local prefix="${branch%%-*}"
  local number="${rest%%-*}"
  if [[ -z "$prefix" || -z "$number" ]]; then
    echo "this_issue: could not parse prefix-number from: $branch" >&2
    return 1
  fi
  chrome "https://linear.app/$LINEAR_PROJECT_NAME/issue/${prefix}-${number}"
}

open-linear() {
  local ticket=$1

  chrome "https://linear.app/$LINEAR_PROJECT_NAME/issue/$ticket"
}

alias this-issue='this_issue'
alias thisissue="this_issue"
alias thisi="this_issue"
