alias company="cdp; cd company; clas;";
alias artist="company";

export TEST_USER_FIRST_NAME="Emerson"

alias linear="chrome https://linear.app/company/my-issues/assigned"
alias lienar="linear"

# Projects
alias ui="company; cd messenger-ui; gst;"
alias be="company; cd company; gst"
alias companybe="company; be;"
alias auth="company; cd messenger-ui-auth; gst;"
alias coats="auth"

alias ai="company; cd creator-ai; gst"

# Git
alias masters="cdp; cd masters; clas"
alias actions="chrome https://github.com/companyco/company/actions"

# Mobile Dev
alias mobile="company; cd messenger-ui-mobile; gst;"
alias mobi="mobile"

# Infra
alias infra="company; cd company-infra; gst"

alias run_android="npx vite build && npx cap sync android && npx cap run android --target Medium_Phone_API_36.1"
alias run_ios="pnpm run build:mobile && pnpm run sync:ios:dev && pnpm run run:ios --target 2F5CAEE7-18ED-4CC6-BDF4-C3E76F5C4021"

alias run_android_device="npx vite build && npx cap sync android && npx cap run android"
alias run-android-device="run_android_device"

alias run-and='run_android'
alias run-android='run_android'
alias run-ios='run_ios'

export CAPAWESOME_TOKEN="<your-token>"

alias dc_rubocop="docker compose exec backend bundle exec rubocop --parallel --cache true"
alias dc_rubocop_a="docker compose exec backend bundle exec rubocop -A --parallel --cache true"
alias dc_test_be="docker compose run --rm backend bundle exec rspec"
alias dc_test_fe="pnpm test:fe --"
alias dc_migrate="docker compose run --rm backend rails db:migrate && pnpm run test:prepare"
alias restart_fe="docker compose restart frontend"

alias restart-fe="restart_fe"
alias res-fe="restart_fe"

alias rails_console="docker compose run --rm backend bundle exec rails console"

alias lintbe="cd apps/core; pnpm lint:eslint;be"

# Branch like dev-24139-some-slug → https://linear.app/company/issue/dev-24139
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
  chrome "https://linear.app/company/issue/${prefix}-${number}"
}

open-linear() {
  local ticket=$1

  chrome "https://linear.app/company/issue/$ticket"
}

alias this-issue='this_issue'
alias thisissue="this_issue"
alias thisi="this_issue"

alias cat_sec="cat ~/Downloads/Security/local.env; echo; echo;"
alias catsec="cat_sec"
