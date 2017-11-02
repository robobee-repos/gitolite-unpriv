#!/bin/bash
set -e

function patch_sshd() {
  sed -i -e "s/UsePrivilegeSeparation yes/UsePrivilegeSeparation no/" /etc/ssh/sshd_config
  sed -i -r -e "s/^#?Port ([[:digit:]]+)/Port ${SSH_PORT}/" /etc/ssh/sshd_config
}

source /docker-entrypoint-utils.sh
set_debug
echo "Running as `id`"
copy_files "/ssh-in" "/etc/ssh" "ssh_host_*"
copy_files "/ssh-in" "/etc/ssh" "sshd_config"
sync_dir "/home/git.dist" "/home/git"
patch_sshd
mkdir -p "${GIT_ROOT}"
cd "${GIT_ROOT}"
exec /init.sh "$@"
