#!/bin/bash

# Set home directory to Docker here:
dockerHome=/home/nuc/docker
nvrHome=/not/yet/used
scriptsHome=/scripts

rootCheck() {
    if [ -z "$1" ]; then
      if [ $(id -u) = 0 ]; then
          echo -e "\e[41m I am root! Run this WITHOUT SUDO, this script has SUDO where needed. \e[0m"
          exit 1
      fi
    fi
}

rebootCheck() {

    if [ -f /var/run/reboot-required ]; then
      cat /var/run/reboot-required
    else echo -e '\e[93mNo reboot is required.\e[0m'
    fi
}

check_exit_status() {

    if [ $? -eq 0 ]
    then
        echo
       #echo -e "\e[93mSuccess\e[0m"
       #echo
    else
      echo
      echo -e "\e[93mERROR Process Failed!\e[0m"
      echo
      if [[ $1 == '-a' ]]
      then
        echo -e "\e[41m AUTO MODE IS ENABLED, EXITING.. \e[0m"
        echo
        exit 1
      else
        read -p "The last command exited with an error. Exit script? (yes/no)? " answer
        if [ "$answer" == "yes" ]
        then
          exit 1
        fi
      fi
    fi
}

greeting() {

    echo -e "\e[93m--------------------------------------------------------------"
    echo -e "\e[93mHello, $USER. Updating all containers I know about and the OS."
    echo -e "\e[93m--------------------------------------------------------------\e[0m"
    echo
}

updateOS() {

    echo -e "\e[93mQuietly updating package information...\e[0m "
    sudo apt update -qq;
    check_exit_status $1
    sudo apt -y upgrade;
    check_exit_status $1
    sudo apt -y autoremove;
    check_exit_status $1
}

updateDocker() {

    if [ -d "$dockerHome" ]; then
      echo -e "\e[93mChecking/Pulling Fresh Docker Containers...-\e[0m"
      composeFile=docker-compose.yml
      cd $dockerHome
      check_exit_status $1
      shopt -s nullglob
      for dname in *; do
          cd $dname
        if test -f "$composeFile"; then
          echo -e "\e[93mOperating on $dname -\e[0m"
          sudo docker-compose pull
          check_exit_status $1
          sudo docker-compose up -d --remove-orphans
          check_exit_status $1
		  docker image prune -f
		  check_exit_status $1
        fi
          cd /home/nuc/docker
          check_exit_status $1
      done
    else
      echo -e "\e[93mThere are no docker files at $dockerHome to update. \e[0m"
    fi
}

updateUpdater() {

    cd "$scriptsHome"
    sudo wget -N https://raw.githubusercontent.com/henroFall/updater/master/updater.sh
    sudo wget -N https://raw.githubusercontent.com/henroFall/updater/master/updateandreboot.sh
    sudo chmod +x updater.sh
    sudo chmod +x updateandreboot.sh
    echo
    echo Retrieved latest version of updater script, will be executed on next run.
    echo
}

pruneDocker() {

    if [ -d "$dockerHome" ]; then
    echo -e "\e[93mCleaning up Docker fragments...\e[0m"
    sudo docker system prune --volumes --force
    check_exit_status $1
    else
    echo -e "\e[93mThere are no docker files at $dockerHome to prune.\e[0m"
    fi
}

showDocker() {

    if [ -d "$dockerHome" ]; then
    echo -e "\e[93m--------------------------------------------------------------"
    echo -e "\e[93mHello again, $USER. Here are the running containers.."
    echo -e "\e[93m--------------------------------------------------------------\e[0m"
    echo
    docker ps
    echo -e "\e[93m--------------------------------------------------------------\e[0m"
    fi
}

getScripts() {
     echo -e "\e[93mUpdloading any new scripts..\e[0m"
    # Need to change things to use git and pull down the whole /scripts folder, and push it back
}

isNVRHere() {
if [ -d "$nvrHome" ]; then
   echo
fi
}

updateNVR() {
   mkdir -p /tmp/ipconfigureDownload
   cd /tmp/ipconfigureDownload
   rm -f -v /tmp/ipconfigureDownload/*
   wget -r -nd -l1 -np -R "index.html*" http://192.168.200.200:8080/ipconfigure/
   mv ./* ./ipconfigure-latest.deb
   check_exit_status
   dpkg -i ipconfigure-latest.deb
   check_exit_status
   apt --fix-broken install
   check_exit_status
}

leave() {

    echo -e "\e[93mUpdate Complete\e[0m"
    echo "Updater last run:" > ~/updater.log
    if [ -z "$1" ]; then
        date >> ~/updater.log
        else
          date >> /home/nuc/updater.log
    fi
    exit
}

########################################################################

greeting $@
rootCheck $@
updateUpdater $@
updateOS $@
updateDocker $@
pruneDocker $@
showDocker $@
leave $@
# isNVRHere $@
# updateNVR $@
rebootCheck $@
