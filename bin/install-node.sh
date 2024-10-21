#!/bin/bash

CURRENT_USER=$(whoami)
export NVM_DIR="/home/$CURRENT_USER/.nvm"
echo $NVM_DIR
mkdir -p $NVM_DIR
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install $(cat /newspack-repos/newspack-plugin/.nvmrc)