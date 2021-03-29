#!/usr/bin/env bash

# Imports
# -------------------------------------------------------------------------------------------------

IMPORT_COMMAND=${IMPORT_COMMAND:-"curl -s"}
REPOSITORY_URL=${REPOSITORY_URL:-"https://raw.githubusercontent.com/delucca/lazyscripts"}
REPOSITORY_BRANCH=${REPOSITORY_BRANCH:-"main"}

source <(eval "${IMPORT_COMMAND}" "${REPOSITORY_URL}/${REPOSITORY_BRANCH}/helpers/handlers.sh")

# Helpers
# -------------------------------------------------------------------------------------------------

function validate_bash_dependency {
  major_version="$(bash --version | head -1 | cut -d ' ' -f 4 | cut -d '.' -f 1)"
  min_major_version="4"

  if [ "${major_version}" -lt "${min_major_version}" ]; then
    throw_error "Your bash major version must be ${min_major_version} or greater"
  fi
}