#!/bin/bash

rootCheck() {
    if [ $(id -u) = 0 ]
    then
        echo -e "\e[41m I AM root! Run WITHOUT SUDO. \e[0m"
        exit 1
    fi
}

check_exit_status() {
    if [ $? -ne 0 ]
    then
        echo -e "\e[41m ERROR: PROCESS FAILED!"
        echo
        read -p "The last command exited with an error. Exit script? (yes/no)" answer
        if [ "$answer" == "yes" ]
        then
            echo -e "EXITING. \e[0m"
            echo
            exit 1
        fi
    fi
}

cleanup() {
    echo
}

#######################################################
rootCheck

echo Installing Updater script.
mkdir -p ~/bin
check_exit_status
sudo mkdir /scripts
check_exit_status
cd /scripts
sudo wget -N https://raw.githubusercontent.com/henroFall/updater/master/updater.sh
sudo chmod +x updater.sh
cd ~/bin
ln -s /scripts/updater.sh updater
check_exit_status
echo 
echo
echo Done. Run by typing:
echo updater
echo