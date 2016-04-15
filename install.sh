#!/usr/bin/env bash

# Code to check archtecture
# if ((1<<32)); then
#   echo 64bits
# else
#   echo 32bits
# fi

# This install the mnode command in /usr/bin/mnode
sudo cp -vf nodem.sh /usr/local/bin/nodem
sudo chmod +x /usr/local/bin/nodem

echo 'export PATH=$HOME/.nodem/bin:$PATH # Add nodem to PATH for scripting' >> ~/.profile
echo 'source $HOME/.profile' >> ~/.zshrc
source ~/.profile

echo -e "\e[32mnodem installed successfully\e[0m"
