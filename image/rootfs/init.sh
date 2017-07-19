#!/bin/bash
set -ex

function backup_sshd() {
  dir="/ssh-in"
  if [ ! -d "${dir}" ]; then
    return
  fi
  cd "${dir}"
  rsync -u -v /etc/ssh/ssh_host_* ./
}

# First, make sure we have a host key; there are multiple host key
# files, we just check that one of them exists.
if [ ! -e /etc/ssh/ssh_host_rsa_key ]; then
  # See if host keys have been defined in the repositories volume
  HOSTKEY_DIR="/home/git/repositories/.ssh/host-keys"
  if [ -e "$HOSTKEY_DIR/ssh_host_rsa_key" ]; then
    echo "Using host key from $HOSTKEY_DIR"
    cp $HOSTKEY_DIR/* /etc/ssh/
  else
    echo "No SSH host keys available. Generating..."
    export LC_ALL=C
    export DEBIAN_FRONTEND=noninteractive
    ssh-keygen -f /etc/ssh/ssh_host_key -N '' -t rsa1
    ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
    ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
    ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa
    ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -N '' -t ed25519
  fi
fi

cd /home/git


# If .ssh has been mounted, ensure it has the right permissions
if [ -d ./.ssh ]; then
   chown -R git:git ./.ssh

else
  CLIENT_DIR="/home/git/repositories/.ssh/client"
  # .ssh does not exist; As an alternative, we allow the .ssh/client
  # folder from the repositories volume to be copied.
  if [ -d "$CLIENT_DIR" ]; then
    echo "Copying files from $CLIENT_DIR to /home/git/.ssh"
    cp -pr $CLIENT_DIR ./.ssh
    chown -R git:git ./.ssh
  fi
fi

# Always make sure the git user has a private key you may
# use for mirroring setups etc.
if [ ! -f ./.ssh/id_rsa ]; then
   ssh-keygen -f /home/git/.ssh/id_rsa  -t rsa -N ''
   echo "Here is the public key of the container's 'git' user:"
   cat /home/git/.ssh/id_rsa.pub
fi

# Support trusting hosts for mirroring setups.
if [ ! -f ./.ssh/known_hosts ]; then
    if [ -n "$TRUST_HOSTS" ]; then
        echo "Generating known_hosts file with $TRUST_HOSTS"
        ssh-keyscan -H $TRUST_HOSTS > /home/git/.ssh/known_hosts
    fi
fi

if [ ! -d ./.gitolite ] ; then

   # gitolite needs to be setup
   if [ -n "$SSH_KEY" ]; then
       echo "Initializing gitolite, while authorizing your selected key for the admin repo"
       echo "$SSH_KEY" > /tmp/admin.pub
       bin/gitolite setup -pk /tmp/admin.pub
       rm /tmp/admin.pub
   else
       # If no SSH key is given, we instead try to support
       # bootstrapping from an existing gitolite-admin.

       # Unfortunately, gitolite setup will add a new
       # commit to an existing gitolite-admin dir that
       # resets everything. We avoid this by renaming it first.
       if [ -d ./repositories/gitolite-admin.git ]; then
           mv ./repositories/gitolite-admin.git ./repositories/gitolite-admin.git-tmp
       fi

       # First, setup gitolite without an ssh key.
       # My understanding is that this is essentially a noop,
       # auth-wise. setup will still generate the .gitolite
       # folder and .gitolite.rc files.
       echo "Initializing gitolite without authorizing a key for accessing the admin repo"
       bin/gitolite setup -a dummy

       # Remove the gitolite-admin repo generated by setup.
       if [ -d ./repositories/gitolite-admin.git-tmp ]; then
           rm -rf ./repositories/gitolite-admin.git
           mv ./repositories/gitolite-admin.git-tmp ./repositories/gitolite-admin.git
       fi

       # Apply config customizations. We need to do this now,
       # because w/o the right config, the compile may fail.
       rcfile=/home/git/.gitolite.rc
       sed -i "s/GIT_CONFIG_KEYS.*=>.*''/GIT_CONFIG_KEYS => \"${GIT_CONFIG_KEYS}\"/g" $rcfile
       if [ -n "$LOCAL_CODE" ]; then
           sed -i "s|# LOCAL_CODE.*=>.*$|LOCAL_CODE => \"${LOCAL_CODE}\",|" $rcfile
       fi

       # Create log directory to prevent cli spew
       mkdir -p .gitolite/logs
       # Setup hooks for following post-update hook call
       bin/gitolite setup --hooks-only

       # We will need to update authorized_keys based on
       # the gitolite-admin repo. The way to do this is by
       # triggering the post-update hook of the gitolite-admin
       # repo (thanks to sitaram for the solution):
       cd /home/git/repositories/gitolite-admin.git && GL_LIBDIR=$(/home/git/bin/gitolite query-rc GL_LIBDIR) PATH=$PATH:/home/git/bin hooks/post-update refs/heads/master
   fi
else
    # Resync on every restart
    bin/gitolite setup
fi


# Allow to specificy "sshd" as a command.
if [ "${1}" = 'sshd' ]; then
  set -- /usr/sbin/sshd -D
fi

backup_sshd
echo "Executing $*"
exec $*