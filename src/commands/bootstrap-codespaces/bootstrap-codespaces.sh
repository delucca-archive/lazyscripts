#!/bin/bash

# REQUIRED DEPENDENCIES
# -------------------------------------------------------------------------------------------------
#
# To run this script, you must have the following tools installed:
# - bash 4
#
# REQUIRED ENVIRONMENT VARIABLE
# -------------------------------------------------------------------------------------------------
#
# Here is the list of required environment variable for this script:
# - SSH_PRIVATE_KEY
# - SSH_PUBLIC_KEY

# Imports
# -------------------------------------------------------------------------------------------------

source <(curl -s "https://raw.githubusercontent.com/delucca/shell-functions/1.0.1/modules/feedback.sh")
source <(curl -s "https://raw.githubusercontent.com/delucca/shell-functions/1.0.1/modules/validation.sh")

# Entrypoint
# -------------------------------------------------------------------------------------------------

function main {
  parse_args $@
  validate_requirements
  
  setup
  post_setup
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

# Install code environment
# -------------------------------------------------------------------------------------------------

function setup {
  log_title "SETUP"

  clear_previous_configs
  execute_install_code_environment_script
}

function clear_previous_configs {
  rm -f "${HOME}/.zshrc"
}

function execute_install_code_environment_script {
  curl -s "https://raw.githubusercontent.com/delucca/lazyscripts/1.0.2/bin/bootstrap-code-env" -o "/tmp/bootstrap-code-env"
  chmod +x "/tmp/bootstrap-code-env"
  /tmp/bootstrap-code-env --complete --minimal
}

# Install code environment
# -------------------------------------------------------------------------------------------------

function post_setup {
  log_title "POST SETUP"

  install_zsh_plugins
  update_local_git_config
}
  
function install_zsh_plugins {
  start_spinner_in_category 'zinit' 'Install plugins'
  
  zsh -ic "@zinit-scheduler burst" &> /dev/null
  
  stop_spinner $?
}

function update_local_git_config {
  start_spinner_in_category 'git' 'Updating local git config'

  rm -f "${HOME}/.gitconfig.local"
  ln -s "${HOME}/.dotfiles/config/gitconfig.codespaces" "${HOME}/.gitconfig.local"

  stop_spinner $?
}

# Helpers
# -------------------------------------------------------------------------------------------------

function help {
  cat << EOF
Setups a Github Codespaces container with all required tools for a proper developer experience.

usage: $0 [OPTIONS]
    --help      Show this message
EOF
}

# Execute
# -------------------------------------------------------------------------------------------------

main $@
