#!/usr/bin/env bash

#
# Set up bash.
#

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
USERNAME=$(logname)

echo "This script will set up your /etc/bash.bashrc, copy bash_style.bash to /etc/scripts and change your terminal settings. By default the files in this repository will be used via symlinks, however, if the files are deleted copies will be used instead."
echo "To proceed enter the sudo password: "
read -s PW

. terminal_dconf.bash

echo $PW | sudo -S mkdir /etc/bash_style 2> /dev/null
echo $PW | sudo -S cp $SCRIPT_DIR/bash_style.bash /etc/bash_style/bash_style.bash.bak 2>/dev/null
echo $PW | sudo -S ln -s $SCRIPT_DIR/bash_style.bash /etc/bash_style/bash_style.bash  2>/dev/null

echo $PW | sudo -S bash -c 'echo "" >> /etc/bash.bashrc'
echo $PW | sudo -S bash -c 'echo '\''if [ -e "/etc/bash_style/bash_style.bash" ]; then'\'' >> /etc/bash.bashrc'
echo $PW | sudo -S bash -c 'echo '\''    source /etc/bash_style/bash_style.bash'\'' >> /etc/bash.bashrc'
echo $PW | sudo -S bash -c 'echo '\''else'\'' >> /etc/bash.bashrc'
echo $PW | sudo -S bash -c 'echo '\''    source /etc/bash_style/bash_style.bash.bak'\'' >> /etc/bash.bashrc'
echo $PW | sudo -S bash -c 'echo '\''fi'\'' >> /etc/bash.bashrc'

unset PW
unset SCRIPT_DIR
unset USERNAME
