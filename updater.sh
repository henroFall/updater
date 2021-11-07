#!/bin/bash

# Set home directories here:
scriptsHome=/scripts
homeHome=$(cat $scriptsHome/home.txt)
dockerHome=$homeHome/docker
teslamateHome=$dockerHome/teslamate
kiosk1=192.168.200.177
kiosk2=192.168.200.178

nvrHome=/opt/orchid


function whereami {
        echo "Searching for location."
        if [[ -d "/opt/amt/IoTGateway" ]]
         then
         whereami="/opt/amt/IoTGateway"
        fi
        if [[ -d "/usr/local/bin/IoTGateway" ]]
         then
         whereami="/usr/local/bin/IoTGateway"
        fi
        if [ -z "$whereami" ]
                then
                echo "NOT here. Exiting."
                exit 1
        fi
}

rootCheck() {
    if [ -z "$1" ]; then
      if [ $(id -u) = 0 ]; then
          echo -e "\e[41m I am root! Run this WITHOUT SUDO, this script has SUDO where needed. \e[0m"
          exit 1
      fi
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
      if [[ $1 == '-auto' ]]
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

killVPN() {

#if [ -x /usr/bin/nordvpn ]; then
if [ -x $scriptsHome/norddown.sh ]; then
    $scriptsHome/norddown.sh
fi

#Service="nordvpnd"
#var=$(service --status-all | grep -w "$Service")
#if [ "output" != "" ]; then
#    nordvpn d
#else
#    echo "NordVPN not installed, not acting to stop VPN."
#fi
}

startVPN() {

#if [ -x /usr/bin/nordvpn ]; then
if [ -x $scriptsHome/nordup.sh ]; then
    $scriptsHome/nordup.sh
fi

#Service="nordvpnd"
#var=$(service --status-all | grep -w "$Service")
#if [ "output" != "" ]; then
#    nordvpn c
#else
#    echo "NordVPN not installed, not acting to connect VPN."
#fi
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
          sudo docker-compose up -d --force-recreate --remove-orphans
          check_exit_status $1
          docker image prune -f
          check_exit_status $1
        fi
          cd $homeHome/docker
          check_exit_status $1
      done
      if [ -d "$teslamateHome" ]; then
      echo -e "\e[93mRestarting Kiosks in 5 minutes...-\e[0m"
        sshpass -p Abc123! ssh pi@kiosk1 'pkill -fe chromium-browser && sudo shutdown -r +5'
        sshpass -p Abc123! ssh pi@kiosk2 'pkill -fe chromium-browser && sudo shutdown -r +5'
      echo -e "\e[93mBacking up TeslaMate...-\e[0m"
      docker-compose exec -T database pg_dump -U teslamate teslamate > /mnt/MediaG/BACKUP/teslamate/teslamate-$(date "+%Y-%m-%d-%H-%M-%S").bck
    fi
      else
        echo -e "\e[93mThere are no docker files at $dockerHome to update. \e[0m"
      fi
}

updateUpdater() {

    cd "$scriptsHome"
    sudo wget -N -q --show-progress https://raw.githubusercontent.com/henroFall/updater/master/updater.sh
    sudo wget -N -q --show-progress https://raw.githubusercontent.com/henroFall/updater/master/updateandreboot.sh
    sudo wget -N -q --show-progress https://raw.githubusercontent.com/henroFall/updater/master/nordup.sh
    sudo wget -N -q --show-progress https://raw.githubusercontent.com/henroFall/updater/master/norddown.sh
    sudo chmod +x updater.sh
    sudo chmod +x updateandreboot.sh
    sudo chmod +x nordup.sh
    sudo chmod +x norddown.sh
    sudo rm -f *.sh.*
    echo
    if [[ $1 == '-updateonly' ]]
      then
      echo Option updateonly enabled.
      exit
    fi
    echo Retrieved latest version of updater script, will be executed on next run.
    echo
}

pruneDocker() {

    if [ -d "$dockerHome" ]; then
    echo -e "\e[93mCleaning up Docker fragments... NO LONGER PRUNING VOLUMES OR NON-DANGLING IMAGES \e[0m"
    docker system prune --force #-a --volumes 
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
    # Idea is for a routine to let me edit scripts locally to tweak, then push back to github
}

isNVRHere() {
if [ -d "$nvrHome" ]; then
   echo
fi
}

updateNVR() {
   echo Looking for NVR...
   if [ -d "$nvrHome" ]; then
     sudo mkdir -p /tmp/ipconfigureDownload
     cd /tmp/ipconfigureDownload
     sudo rm -f -v /tmp/ipconfigureDownload/*
     sudo wget -nv -r -nd -l1 -np -R "index.html*" http://192.168.200.200:8080/ipconfigure/
     sudo mv ./* ./ipconfigure-latest.deb
     #sudo dpkg -i ipconfigure-latest.deb
     sudo apt --fix-broken install
   fi
}


rebootCheck() {
    if [[ $1 != '-auto' ]]
      then
    needrestart -r i
    fi
}

leave() {

    echo -e "\e[93mUpdate Complete\e[0m"
    if [ -z "$1" ]; then
        #touch $homeHome/updater.log
        echo "Updater last run:" > $homeHome/updater.log
        date >> $homeHome/updater.log
        else
          #touch $homeHome/updater.log
          echo "Updater last run:" > $dockerHome/updater.log
          date >> $dockerHome/updater.log
    fi
    exit
}

########################################################################

greeting $@
rootCheck $@
# killVPN $@
updateUpdater $@
updateOS $@
updateDocker $@
pruneDocker $@
showDocker $@
# startVPN $@
rebootCheck $@
updateNVR $@
leave $@

# isNVRHere $@

