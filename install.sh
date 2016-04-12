#!/usr/bin/env bash

# Code to check archtecture
# if ((1<<32)); then
#   echo 64bits
# else
#   echo 32bits
# fi

# This install the mnode command in /usr/bin/mnode
sudo cp -vf nvm.sh /usr/local/bin/nvm
sudo chmod +x /usr/local/bin/nvm

echo 'export PATH=$HOME/.nvm/bin:$PATH # Add NVM to PATH for scripting' >> ~/.profile

echo -e "\e[32mnvm installed successfully\e[0m"
