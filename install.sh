#!/usr/bin/env bash

sudo wget https://raw.githubusercontent.com/marcoT89/nodem/master/nodem.sh -P /usr/local/bin/
sudo chmod +x /usr/local/bin/nodem

echo 'export PATH=$HOME/.nodem/bin:$PATH # Add nodem to PATH for scripting' >> ~/.profile
echo 'source $HOME/.profile' >> ~/.zshrc
source ~/.profile

echo -e "\033[32mnodem installed successfully\033[0m"
