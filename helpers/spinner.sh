#!/usr/bin/env bash

# Imports
# -------------------------------------------------------------------------------------------------

REPOSITORY_URL=${REPOSITORY_URL:-"https://raw.githubusercontent.com/delucca/lazyscripts"}
REPOSITORY_BRANCH=${REPOSITORY_BRANCH:-"main"}

source <(curl -s "${REPOSITORY_URL}/${REPOSITORY_BRANCH}/helpers/spinner.sh")

# Helpers
# -------------------------------------------------------------------------------------------------

function start_spinner_in_category {
  category=$1
  message=$2

  full_message="  \x1B[36m\r➤\e[1m ${category}:\x1B[0m ${message}"

  start_spinner "${full_message}"
}