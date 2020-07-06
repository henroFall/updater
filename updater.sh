#!/bin/bash

rootCheck() {

    if [ $(id -u) = 0 ]; 
    then
        echo -e "\e[41m I am root! Run this WITHOUT SUDO, this script has SUDO where needed. \e[0m"
        exit 1
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
          check_exit_status $1
          sudo docker-compose down
          check_exit_status $1
          sudo docker-compose pull
          check_exit_status $1
          sudo docker-compose up -d
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

    cd /scripts
    sudo wget -N https://raw.githubusercontent.com/henroFall/updater/master/updater.sh
	echo
	echo Retrieved latest version of updater script, will be executed on next run.
	echo
}

pruneDocker() {

    if [ -d "$dockerHome" ]; then
    echo -e "\e[93mCleaning up Docker fragments...\e[0m"
    sudo docker system prune -f
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

leave() {

    echo -e "\e[93mUpdate Complete\e[0m"
    exit
}
########################################################################

dockerHome=~/docker
greeting $@
rootCheck $@
updateUpdater $@
updateOS $@
updateDocker $@
pruneDocker $@
showDocker $@
leave $@
rebootCheck $@