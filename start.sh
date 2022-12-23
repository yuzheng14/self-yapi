#!/bin/zsh
source ~/.zshrc 
nvm use 12 
nohup mongod &
sleep 10
# npm run install-server;
# sleep 5
node server/app.js