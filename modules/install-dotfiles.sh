#!/bin/bash

# REQUIRED DEPENDENCIES
# -------------------------------------------------------------------------------------------------
#
# To run this script, you must have the following tools installed:
# - bash 4

# Imports
# -------------------------------------------------------------------------------------------------

source <(curl -s "https://raw.githubusercontent.com/delucca/shell-functions/1.0.1/modules/feedback.sh")
source <(curl -s "https://raw.githubusercontent.com/delucca/shell-functions/1.0.1/modules/validation.sh")

# Global variables
# -------------------------------------------------------------------------------------------------

MINIMAL=false

# Entrypoint
# -------------------------------------------------------------------------------------------------

function main {
  parse_args $@
  validate_requirements
  prepare

  setup_dotfiles
}

# Parse args
# -------------------------------------------------------------------------------------------------

function parse_args {
  for opt in "$@"; do
    case $opt in
      --help)
        help
        exit 0
        ;;
      --minimal) MINIMAL=true ;;
      *)
        echo "unknown option: $opt"
        help
        exit 1
        ;;
    esac
  done
}

# Validate
# -------------------------------------------------------------------------------------------------

function validate_requirements {
  validate_dependencies
}

function validate_dependencies {
  validate_bash_dependency
}

# Prepare
# -------------------------------------------------------------------------------------------------

function prepare {
  install_dotfiles_manager
  clear_previous_installation
  clone_dotfiles_repository
}

function install_dotfiles_manager {
  start_spinner_in_category 'fresh' 'Installing'

  bash -c "`curl -sL https://get.freshshell.com`" > /dev/null

  stop_spinner $?
}

function clear_previous_installation {
  start_spinner_in_category 'clear' 'Removing previous installations'

  rm -rf "${HOME}/.dotfiles"
  sudo rm -f "${HOME}/.freshrc"

  stop_spinner $?
}

function clone_dotfiles_repository {
  start_spinner_in_category 'repository' 'Cloning dotfiles'

  git clone --quiet https://github.com/delucca/dotfiles.git "${HOME}/.dotfiles" &> /dev/null

  stop_spinner $?
}

# Setup dotfiles
# -------------------------------------------------------------------------------------------------

function setup_dotfiles {
  add_symlinks
  sync_dotfiles
}

function add_symlinks {
  dotfile=$([ "${MINIMAL}" = true ] && echo "${HOME}/.dotfiles/freshrc.min" || echo "${HOME}/.dotfiles/freshrc")

  ln -s "${dotfile}" "${HOME}/.freshrc"
}

function sync_dotfiles {
  start_spinner_in_category 'fresh' 'Syncing dotfiles'

  source "${HOME}/.fresh/build/shell.sh" 2> /dev/null
  fresh > /dev/null

  stop_spinner $?
}

# Helpers
# -------------------------------------------------------------------------------------------------

function help {
  cat << EOF
Installs my Dotfiles. Those files are used to customize all my tools as I want.

usage: $0 [OPTIONS]
    --help           Show this message
    --minimal        Install only the minimal required tools
EOF
}

# Execute
# -------------------------------------------------------------------------------------------------

main $@
