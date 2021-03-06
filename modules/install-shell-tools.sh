#!/bin/bash

# WHICH OS/DISTROS ARE SUPPORTED
# -------------------------------------------------------------------------------------------------
#
# For now, this script only works in the following list of operating systems:
# - Linux
#
# Considering your OS as Linux, it only works in the following distros:
# - elementary OS Hera
# - Debian
#
# REQUIRED DEPENDENCIES
# -------------------------------------------------------------------------------------------------
#
# To run this script, you must have the following tools installed:
# - bash 4

# Imports
# -------------------------------------------------------------------------------------------------

source <(curl -s "https://raw.githubusercontent.com/delucca/shell-functions/1.0.1/modules/feedback.sh")
source <(curl -s "https://raw.githubusercontent.com/delucca/shell-functions/1.0.1/modules/validation.sh")
source <(curl -s "https://raw.githubusercontent.com/delucca/shell-functions/1.0.1/modules/authorization.sh")

# Global variables
# -------------------------------------------------------------------------------------------------

DISTRO="${UNKNOWN}"
DISTRO_ELEMENTARY="ELEMENTARY"
DISTRO_DEBIAN="DEBIAN"

MINIMAL=false

# Entrypoint
# -------------------------------------------------------------------------------------------------

function main {
  parse_args $@
  validate_requirements
  prepare

  install_minimal
  install_full
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
  validate_os
  validate_distro
  validate_dependencies
}

function validate_os {
  linux_os="LINUX"
  unknown_os="${UNKNOWN}"
  uname_output="$(uname -s)"

  case "${uname_output}" in
    Linux*) current_os="${linux_os}";;
    *) current_os="${unknown_os}"
  esac

  if [ "${current_os}" = "${unknown_os}" ]; then
    throw_error "Your operating system is not supported"
  fi
}

function validate_distro {
  elementary_os_distro="${DISTRO_ELEMENTARY}"
  debian_distro="${DISTRO_DEBIAN}"
  unknown_distro="${UNKNOWN}"
  lsb_output="$(lsb_release -si)"

  case "${lsb_output}" in
    Elementary*) current_distro="${elementary_os_distro}";;
    Debian*) current_distro="${debian_distro}";;
    *) current_distro="${unknown_distro}"
  esac

  if [ "${current_distro}" = "${unknown_distro}" ]; then
    throw_error "Your Linux distro is not supported"
  fi

  identify_distro ${current_distro}
}

function identify_distro {
  identified_distro=$1
  DISTRO="${identified_distro}"
}

function validate_dependencies {
  validate_bash_dependency
}

# Prepare
# -------------------------------------------------------------------------------------------------

function prepare {
  update_su_timestamp

  case "${DISTRO}" in
    ${DISTRO_ELEMENTARY}) prepare_debian;;
    ${DISTRO_DEBIAN}) prepare_debian;;
    ${UNKNOWN}) throw_error "You first need to identify a distro";;
    *) throw_error "We don't have a prepare function for your distro: ${DISTRO}"
  esac
}

function prepare_debian {
  start_spinner_in_category 'Prepare' 'Updating your apt repositories'

  sudo apt-get -y update &> /dev/null

  stop_spinner $?
}

# Install minimal
# -------------------------------------------------------------------------------------------------

function install_minimal {
  log_title "MINIMAL SHELL TOOLS"

  install_xclip
  install_fzf
  install_fd
  install_tree
  install_ripgrep
  install_starship
  install_zsh
  install_zinit
}

function install_xclip {
  case "${DISTRO}" in
    ${DISTRO_ELEMENTARY}) install_xclip_debian;;
    ${DISTRO_DEBIAN}) install_xclip_debian;;
    ${UNKNOWN}) throw_error "You first need to identify a distro";;
    *) throw_error "We don't have a xclip installer for your distro: ${DISTRO}"
  esac
}

function install_xclip_debian {
  start_spinner_in_category 'xclip' 'Installing'

  sudo apt-get install xclip -y > /dev/null

  stop_spinner $?
}

function install_fzf {
  start_spinner_in_category 'fzf' 'Cloning'

  git_repo_location=$([ -d "/home/git" ] && echo "/home/git/junegunn/fzf" || echo "${HOME}/.fzf")
  [ -d "${git_repo_location}" ] && rm -rf ${git_repo_location}
  git clone --quiet --depth 1 https://github.com/junegunn/fzf.git "${git_repo_location}" > /dev/null

  stop_spinner $?
  start_spinner_in_category 'fzf' 'Installing'
  
  "${git_repo_location}/install" --completion --no-key-bindings --no-update-rc &> /dev/null

  stop_spinner $?
}

function install_fd {
  start_spinner_in_category 'fd' 'Downloading'

  pushd /tmp > /dev/null
  curl https://github.com/sharkdp/fd/releases/download/v8.2.1/fd_8.2.1_amd64.deb -Lso fd.deb

  stop_spinner $?
  start_spinner_in_category 'fd' 'Installing'

  sudo dpkg -i fd.deb > /dev/null

  stop_spinner $?

  popd > /dev/null
}

function install_tree {
  case "${DISTRO}" in
    ${DISTRO_ELEMENTARY}) install_tree_debian;;
    ${DISTRO_DEBIAN}) install_tree_debian;;
    ${UNKNOWN}) throw_error "You first need to identify a distro";;
    *) throw_error "We don't have a tree installer for your distro: ${DISTRO}"
  esac
}

function install_tree_debian {
  start_spinner_in_category 'jq' 'Installing'

  sudo apt-get install tree -y > /dev/null

  stop_spinner $?
}

function install_ripgrep {
  start_spinner_in_category 'ripgrep' 'Downloading'

  pushd /tmp > /dev/null
  curl https://github.com/BurntSushi/ripgrep/releases/download/12.1.1/ripgrep_12.1.1_amd64.deb -Lso ripgrep.deb > /dev/null

  stop_spinner $?
  start_spinner_in_category 'ripgrep' 'Installing'

  sudo dpkg -i ripgrep.deb > /dev/null

  stop_spinner $?

  popd > /dev/null
}

function install_starship {
  start_spinner_in_category 'starship' 'Downloading installation script'

  curl -fsSL https://starship.rs/install.sh -Lso "/tmp/starship_install.sh"
  chmod +x "/tmp/starship_install.sh"
  
  stop_spinner $?
  start_spinner_in_category 'starship' 'Installing'
  
  /tmp/starship_install.sh -y > /dev/null

  stop_spinner $?
}

function install_zsh {
  case "${DISTRO}" in
    ${DISTRO_ELEMENTARY}) install_zsh_debian;;
    ${DISTRO_DEBIAN}) install_zsh_debian;;
    ${UNKNOWN}) throw_error "You first need to identify a distro";;
    *) throw_error "We don't have a zsh installer for your distro: ${DISTRO}"
  esac
}

function install_zsh_debian {
  start_spinner_in_category 'zsh' 'Installing'

  sudo apt-get install zsh -y > /dev/null

  stop_spinner $?
}

function install_zinit {
  start_spinner_in_category 'zinit' 'Installing'

  rm -rf "${HOME}/.zinit" || true
  mkdir "${HOME}/.zinit"

  git clone --quiet https://github.com/zdharma/zinit.git "${HOME}/.zinit/bin" > /dev/null

  stop_spinner $?
}

# Install full
# -------------------------------------------------------------------------------------------------

function install_full {
  if [ "${MINIMAL}" = false ]; then
    log_title "FULL SHELL TOOLS"

    install_ack
    install_jq
    install_ag
    install_navi
    install_bat
    install_bat_extras
    install_tmux
    install_bottom
    install_keychain
  fi
}

function install_ack {
  case "${DISTRO}" in
    ${DISTRO_ELEMENTARY}) install_ack_debian;;
    ${DISTRO_DEBIAN}) install_ack_debian;;
    ${UNKNOWN}) throw_error "You first need to identify a distro";;
    *) throw_error "We don't have a ack installer for your distro: ${DISTRO}"
  esac
}

function install_ack_debian {
  start_spinner_in_category 'ack' 'Installing'

  sudo apt-get install ack-grep -y > /dev/null

  stop_spinner $?

  sudo dpkg-divert --local --divert /usr/bin/ack --rename --add /usr/bin/ack-grep > /dev/null
}

function install_jq {
  case "${DISTRO}" in
    ${DISTRO_ELEMENTARY}) install_jq_debian;;
    ${DISTRO_DEBIAN}) install_jq_debian;;
    ${UNKNOWN}) throw_error "You first need to identify a distro";;
    *) throw_error "We don't have a jq installer for your distro: ${DISTRO}"
  esac
}

function install_jq_debian {
  start_spinner_in_category 'jq' 'Installing'

  sudo apt-get install jq -y > /dev/null

  stop_spinner $?
}

function install_ag {
  case "${DISTRO}" in
    ${DISTRO_ELEMENTARY}) install_ag_debian;;
    ${DISTRO_DEBIAN}) install_ag_debian;;
    ${UNKNOWN}) throw_error "You first need to identify a distro";;
    *) throw_error "We don't have a ag installer for your distro: ${DISTRO}"
  esac
}

function install_ag_debian {
  start_spinner_in_category 'ag' 'Installing'

  sudo apt-get install silversearcher-ag -y > /dev/null
  
  stop_spinner $?
}

function install_navi {
  start_spinner_in_category 'navi' 'Downloading'

  pushd /tmp > /dev/null
  curl https://raw.githubusercontent.com/denisidoro/navi/master/scripts/install -Lso "install_navi.sh" > /dev/null

  stop_spinner $?
  start_spinner_in_category 'navi' 'Installing'

  chmod +x "./install_navi.sh"
  sudo "./install_navi.sh" &> /dev/null

  stop_spinner $?

  popd > /dev/null
}

function install_bat {
  start_spinner_in_category 'bat' 'Downloading'

  pushd /tmp > /dev/null
  curl https://github.com/sharkdp/bat/releases/download/v0.18.0/bat_0.18.0_amd64.deb -Lso bat.deb

  stop_spinner $?
  start_spinner_in_category 'bat' 'Installing'

  sudo dpkg -i bat.deb > /dev/null

  stop_spinner $?

  popd > /dev/null
}

function install_bat_extras {
  start_spinner_in_category 'bat-extras' 'Downloading'

  pushd /tmp > /dev/null
  curl https://github.com/eth-p/bat-extras/releases/download/v2020.10.05/bat-extras-20201005.zip -Lso bat-extras.zip > /dev/null

  stop_spinner $?
  start_spinner_in_category 'bat-extras' 'Installing'

  unzip -o ./bat-extras.zip -d bat-extras > /dev/null

  stop_spinner $?

  chmod +x bat-extras/bin/*
  sudo mv bat-extras/bin/* /usr/bin

  popd > /dev/null
}

function install_tmux {
  case "${DISTRO}" in
    ${DISTRO_ELEMENTARY}) install_tmux_debian;;
    ${DISTRO_DEBIAN}) install_tmux_debian;;
    ${UNKNOWN}) throw_error "You first need to identify a distro";;
    *) throw_error "We don't have a tmux installer for your distro: ${DISTRO}"
  esac

  install_tpm
  install_tmuxinator
}

function install_tmux_debian {
  start_spinner_in_category 'tmux' 'Installing'

  sudo apt-get install tmux -y > /dev/null

  stop_spinner $?
}

function install_tpm {
  start_spinner_in_category 'tpm' 'Installing'

  git clone --quiet https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm" &> /dev/null

  stop_spinner $?
}

function install_tmuxinator {
  start_spinner_in_category 'tmuxinator' 'Installing rubygems'

  sudo apt-get install rubygems -y > /dev/null

  stop_spinner $?
  start_spinner_in_category 'tmuxinator' 'Installing'

  sudo gem install tmuxinator -v 1.1.5 > /dev/null

  stop_spinner $?
  start_spinner_in_category 'tmuxinator' 'Installing autocompletions'

  sudo wget -q https://raw.githubusercontent.com/tmuxinator/tmuxinator/master/completion/tmuxinator.zsh -O /usr/local/share/zsh/site-functions/_tmuxinator > /dev/null

  stop_spinner $?
}

function install_bottom {
  case "${DISTRO}" in
    ${DISTRO_ELEMENTARY}) install_bottom_debian;;
    ${DISTRO_DEBIAN}) install_bottom_debian;;
    ${UNKNOWN}) throw_error "You first need to identify a distro";;
    *) throw_error "We don't have a bottomm installer for your distro: ${DISTRO}"
  esac
}

function install_bottom_debian {
  start_spinner_in_category 'bottom' 'Downloading'

  pushd /tmp > /dev/null
  curl https://github.com/ClementTsang/bottom/releases/download/0.5.7/bottom_0.5.7_amd64.deb -Lso bottom.deb > /dev/null

  stop_spinner $?
  start_spinner_in_category 'bottom' 'Installing'

  sudo dpkg -i bottom.deb > /dev/null &

  stop_spinner $?

  popd > /dev/null
}

function install_keychain {
  case "${DISTRO}" in
    ${DISTRO_ELEMENTARY}) install_keychain_debian;;
    ${DISTRO_DEBIAN}) install_keychain_debian;;
    ${UNKNOWN}) throw_error "You first need to identify a distro";;
    *) throw_error "We don't have a keychain installer for your distro: ${DISTRO}"
  esac
}

function install_keychain_debian {
  start_spinner_in_category 'keychain' 'Installing'

  sudo apt-get install keychain -y > /dev/null

  stop_spinner $?
}

# Helpers
# -------------------------------------------------------------------------------------------------

function help {
  cat << EOF
Installs my Shell tools. Those tools are used for both debug and shell general usage.

usage: $0 [OPTIONS]
    --help           Show this message
    --minimal        Install only the minimal required tools
EOF
}

# Execute
# -------------------------------------------------------------------------------------------------

main $@
