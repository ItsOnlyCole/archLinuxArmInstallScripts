#!/bin/bash

#----------
# Variables
#----------
serverName=$1
userName=$2


#----------
# Functions
#----------
function help () {
	if [[ "$serverName" == "--help" ]] || [[ "$severName" == "-h" ]]
	then
		echo "Run as su"
		echo "./serverSetup.sh [Hostname] [Username] [Password]"
		exit 0
	fi
}


function initPopKeys () {
	echo
	echo "Initializing and populating Keyring..."
	echo
	pacman-key --init
	pacman-key --populate archlinuxarm
}

function updateRepos () {
	echo
	echo "Upgrading System..."
	echo
	yes | pacman -Syu
}

function installGitDevel () {
	#Installing Git and Base-Devel for Yay after reboot
	echo
	echo "Installing Git & Base-Devel..."
	echo
	yes | pacman -S git
	pacman -S --noconfirm base-devel
}

function configureHostName () {
	echo
	echo "Configuring Hostname..."
	echo
	if [[ $serverName != "" ]]
	then
		rm /etc/hostname
		echo $serverName > /etc/hostname
	fi        
}

function configureSudo () {
	echo
	echo "Configuring Sudo..."
	echo
	yes | pacman -S sudo
	sed -e 's/# %sudo/%sudo/' /etc/sudoers
	groupadd sudo
}

function createUser () {
	if [[ $userName != "" ]]
	then
		echo
		echo "Creating new User..."
		echo
		#Create new user in Wheel & Sudo groups
		useradd -m -G wheel,sudo -s /bin/bash $userName
		#echo $userName:$pw | chpasswd

		#Removes old alarm user
		echo
		echo "Remove old alarm user..."
		echo
		userdel -r alarm
	else
		#If no new user, alarm gains sudo access
		echo
		echo "Giving alarm sudo access"
		echo
		usermod -aG sudo alarm
	fi
}


#---------------
# Code Execution
#---------------
help

#Initializes and Populates Keyrings and Keys
initPopKeys

updateRepos

#Installs Git and Base-Devel for Yay installation
installGitDevel

configureHostName

configureSudo

createUser

echo "Run passwd $userName to set your password"
echo
echo "run these commands as standard user to install yay"
echo "git clone https://aur.archlinux.org/yay.git"
echo "cd yay"
echo "makepkg -si"

echo "Afterwards, reboot then setup is complete!"
echo "sudo shutdown -r 0"

#-----
# end
#-----
