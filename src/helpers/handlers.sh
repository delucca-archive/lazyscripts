#!/usr/bin/env bash

# Imports
# -------------------------------------------------------------------------------------------------

source <(curl -s https://raw.githubusercontent.com/delucca/lazyscripts/main/src/helpers/log.sh)

# Helpers
# -------------------------------------------------------------------------------------------------

function throw_error {
  message=$1

  log_error "${message}"
  exit 1
}