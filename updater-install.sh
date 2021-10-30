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
sudo wget -q --show-progress https://raw.githubusercontent.com/henroFall/updater/master/updater.sh
sudo wget -q --show-progress https://raw.githubusercontent.com/henroFall/updater/master/updateandreboot.sh
sudo wget -q --show-progress https://raw.githubusercontent.com/henroFall/updater/master/nordup.sh
sudo wget -q --show-progress https://raw.githubusercontent.com/henroFall/updater/master/norddown.sh
echo $HOME > ~/home.txt
homeHome=$HOME
sudo mv $homeHome/home.txt /scripts/home.txt
sudo chmod +x updater.sh
sudo chmod +x updateandreboot.sh
sudo chmod +x nordup.sh
sudo chmod +x norddown.sh
cd ~/bin
ln -s /scripts/updater.sh updater
check_exit_status
echo 
echo
sudo apt -y update
sudo apt -y install needrestart sshpass
echo Done. Schedule updateandreboot.sh in crontab.
echo Run on demand by typing:
echo
echo updater
echo
echo AFTER YOU REBOOT
