#!/usr/bin/env bash

# Imports
# -------------------------------------------------------------------------------------------------

source <(curl -s https://raw.githubusercontent.com/tlatsas/bash-spinner/master/spinner.sh)

# Helpers
# -------------------------------------------------------------------------------------------------

function start_spinner_in_category {
  category=$1
  message=$2

  full_message="  \x1B[36m\r➤\e[1m ${category}:\x1B[0m ${message}"

  start_spinner "${full_message}"
}