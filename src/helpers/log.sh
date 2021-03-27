#!/usr/bin/env bash

# Helpers
# -------------------------------------------------------------------------------------------------

function log_title {
  message=$1

  bold=$(tput bold)
  reset=$(tput sgr0)
  magenta=$(tput setaf 5)
  number_of_columns="$(($(tput cols)-27))"
  separator_spaces=$(printf "%${number_of_columns}s")

  echo
  echo "${bold}${magenta}${message}${reset}"
  echo ${separator_spaces// /-}
}

function log_error {
  message=$1

  bold=$(tput bold)
  reset=$(tput sgr0)
  red=$(tput setaf 1)

  echo "${bold}${red}Error:${reset}"
  echo "${red}  ${message}${reset}"
}