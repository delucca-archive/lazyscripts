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
  log_title "MINIMAL DEV TOOLS"

  install_diff_so_fancy
}

function install_diff_so_fancy {
  start_spinner_in_category 'diff-so-fancy' 'Cloning'

  git_repo_location=$([ -d "/home/git" ] && echo "/home/git/so-fancy/diff-so-fancy" || echo "${HOME}/.diff-so-fancy")
  [ -d "${git_repo_location}" ] && rm -rf ${git_repo_location}
  git clone --quiet https://github.com/so-fancy/diff-so-fancy "${git_repo_location}" > /dev/null

  stop_spinner $?

  start_spinner_in_category 'diff-so-fancy' 'Linking binaries'

  bin_file="${HOME}/.local/bin/diff-so-fancy"

  chmod +x "${git_repo_location}/diff-so-fancy"

  rm -f "${bin_file}"
  ln -s "${git_repo_location}/diff-so-fancy" "${bin_file}"

  stop_spinner $?
}

# Install full
# -------------------------------------------------------------------------------------------------

function install_full {
  if [ "${MINIMAL}" = false ]; then
    log_title "FULL DEV TOOLS"

    install_latest_git
    install_docker
    install_docker_compose
    install_kubectl
    install_kubectx
    install_go
    install_terraform
    install_mycli
    install_pgcli
    install_aws_cli
    install_minikube
  fi
}

function install_latest_git {
  case "${DISTRO}" in
    ${DISTRO_ELEMENTARY}) install_latest_git_debian;;
    ${DISTRO_DEBIAN}) install_latest_git_debian;;
    ${UNKNOWN}) throw_error "You first need to identify a distro";;
    *) throw_error "We don't have a latest_git installer for your distro: ${DISTRO}"
  esac
}

function install_latest_git_debian {
  start_spinner_in_category 'git' 'Adding repositories'

  sudo apt-get install software-properties-common -y > /dev/null
  sudo apt-get update -y > /dev/null
  sudo add-apt-repository ppa:git-core/ppa -y > /dev/null

  stop_spinner $?
  start_spinner_in_category 'git' 'Updating repositories'

  sudo apt-get update -y > /dev/null

  stop_spinner $?
  start_spinner_in_category 'git' 'Installing latest version'

  sudo apt-get install git -y > /dev/null

  stop_spinner $?
}

function install_docker {
  start_spinner_in_category 'Docker' 'Adding requirements'

  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor --yes -o /usr/share/keyrings/docker-archive-keyring.gpg > /dev/null
  sudo apt-get update -y > /dev/null

  sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y > /dev/null

  stop_spinner $?
  start_spinner_in_category 'Docker' 'Installing'

  sudo apt-get update -y > /dev/null
  sudo apt-get install docker.io -y > /dev/null

  stop_spinner $?
  start_spinner_in_category 'Docker' 'Removing sudo requirements'

  sudo groupadd docker > /dev/null
  sudo usermod -aG docker $USER > /dev/null

  stop_spinner $?
}

function install_docker_compose {
  start_spinner_in_category 'docker-compose' 'Installing'

  sudo curl -Ls "https://github.com/docker/compose/releases/download/1.28.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose > /dev/null
  sudo chmod +x /usr/local/bin/docker-compose > /dev/null

  stop_spinner $?
}

function install_kubectl {
  start_spinner_in_category 'kubectl' 'Installing'

  curl -LsO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" > /dev/null
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl > /dev/null

  stop_spinner $?
}

function install_kubectx {
  start_spinner_in_category 'kubectx' 'Downloading'

  cd /tmp
  wget https://github.com/ahmetb/kubectx/releases/download/v0.9.3/kubectx_v0.9.3_linux_x86_64.tar.gz --quiet > /dev/null

  stop_spinner $?
  start_spinner_in_category 'kubectx' 'Installing'

  tar -xvf kubectx_v0.9.3_linux_x86_64.tar.gz > /dev/null
  chmod +x kubectx > /dev/null
  mv kubectx ~/.local/bin > /dev/null

  stop_spinner $?
}

function install_go {
  start_spinner_in_category 'go' 'Downloading'

  cd /tmp
  curl -LsO https://dl.google.com/go/go1.12.7.linux-amd64.tar.gz > /dev/null

  stop_spinner $?
  start_spinner_in_category 'go' 'Installing'

  tar xvf go1.12.7.linux-amd64.tar.gz > /dev/null
  sudo mv go /usr/local > /dev/null

  stop_spinner $?
  start_spinner_in_category 'go' 'Creating folder structure'

  sudo useradd go > /dev/null
  sudo bash -c 'cat<<EOF >/var/lib/AccountsService/users/go
[User]
SystemAccount=true
EOF' > /dev/null
  sudo mkhomedir_helper go > /dev/null
  sudo setfacl -R -m user:${USER}:rwx ~go > /dev/null

  stop_spinner $?
}

function install_terraform {
  start_spinner_in_category 'Terraform' 'Adding repository'

  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key add - > /dev/null
  sudo apt-get install software-properties-common -y > /dev/null
  sudo apt-get update -y > /dev/null
  sudo apt-add-repository -y "deb [arch=amd64] https://apt.releases.hashicorp.com bionic main" > /dev/null

  stop_spinner $?
  start_spinner_in_category 'Terraform' 'Installing'

  sudo apt-get update -y > /dev/null
  sudo apt-get install terraform -y> /dev/null

  stop_spinner $?
}

function install_mycli {
  start_spinner_in_category 'mycli' 'Installing'

  sudo apt-get install mycli -y > /dev/null

  stop_spinner $?
}

function install_pgcli {
  start_spinner_in_category 'pgcli' 'Installing'

  sudo apt-get install pgcli -y > /dev/null

  stop_spinner $?
}

function install_aws_cli {
  start_spinner_in_category 'aws-cli' 'Downloading'

  cd /tmp
  curl -Ls "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" > /dev/null

  stop_spinner $?
  start_spinner_in_category 'aws-cli' 'Installing'

  unzip awscliv2.zip > /dev/null
  sudo ./aws/install > /dev/null

  stop_spinner $?
}

function install_minikube {
  start_spinner_in_category 'minikube' 'Downloading'

  cd /tmp
  curl -LsO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb > /dev/null

  stop_spinner $?
  start_spinner_in_category 'minikube' 'Installing'

  sudo dpkg -i minikube_latest_amd64.deb > /dev/null

  stop_spinner $?
  start_spinner_in_category 'minikube' 'Configuring data folder'

  sudo useradd minikube > /dev/null
  sudo bash -c 'cat<<EOF >/var/lib/AccountsService/users/minikube
[User]
SystemAccount=true
EOF' > /dev/null
  sudo mkhomedir_helper minikube > /dev/null
  sudo bash -c 'cat<<EOF >/etc/systemd/system/home-minikube-.minikube.mount
[Unit]
Description=Bind mount for my Minikube folder

[Mount]
What=/mnt/hdd0/minikube
Where=/home/minikube/.minikube
Type=none
Options=bind

[Install]
WantedBy=local-fs.target
EOF' > /dev/null

  sudo mkdir /home/minikube/.minikube > /dev/null
  sudo chown -R minikube:minikube /home/minikube/.minikube > /dev/null
  sudo setfacl -R -m user:${USER}:rwx ~minikube > /dev/null
  sudo systemctl start home-minikube-.minikube.mount > /dev/null
  sudo systemctl enable home-minikube-.minikube.mount > /dev/null

  stop_spinner $?
}

# Helpers
# -------------------------------------------------------------------------------------------------

function help {
  cat << EOF
Installs my Development tools. Those tools are used to develop applications and softwares.

usage: $0 [OPTIONS]
    --help           Show this message
    --minimal        Install only the minimal required tools
EOF
}

# Execute
# -------------------------------------------------------------------------------------------------

main $@
