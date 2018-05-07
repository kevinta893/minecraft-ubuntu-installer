#!/bin/sh
#intended for Ubuntu installs


#initial settings
MCMYADMIN_INITIAL_PASSWORD=pleasechangeme
TIMEZONE=America/Edmonton
MINECRAFT_PORT=25565



#update system first
sudo apt-get -y update

#=======================
#General setup

#install Java 8 runtime
sudo apt-get -y install openjdk-8-jre


#setup timezone for your server. To see avaliable timezones on linux, see "ls /usr/share/zoneinfo" and copy the appropriate timezone file
sudo cp /usr/share/zoneinfo/$TIMEZONE /etc/localtime
w

#Other tools
sudo apt-get -y install unzip
sudo apt-get -y install nano
sudo apt-get -y install wget
sudo apt-get -y install cron

#=============
#setup AWS CLI for backups

echo "========================"
echo "Installing AWS CLI Tool"

#python
sudo apt-get -y install python
sudo apt-get -y install python-pip
sudo pip install --upgrade pip

#amazon aws CLI tool
pip install awscli --upgrade --user
echo "Setup your AWS configurations now. You can also skip by entering nothing for the fields"
aws configure




#======================
#install McMyAdmin

echo "========================"
echo "Installing McMyAdmin"

#root required here
cd /usr/local
sudo wget http://mcmyadmin.com/Downloads/etc.zip
sudo unzip etc.zip
sudo rm etc.zip

#no root required
mkdir ~/McMyAdmin
cd ~/McMyAdmin
wget http://mcmyadmin.com/Downloads/MCMA2_glibc26_2.zip
unzip MCMA2_glibc26_2.zip
rm MCMA2_glibc26_2.zip
./MCMA2_Linux_x86_64 -updateonly
./MCMA2_Linux_x86_64 -setpass $MCMYADMIN_INITIAL_PASSWORD -configonly


#Auto accept EULA
echo "Auto accepting the Minecraft EULA, see https://account.mojang.com/documents/minecraft_eula"
mkdir ~/McMyAdmin/Minecraft/
echo "eula=true" > ~/McMyAdmin/Minecraft/eula.txt

#Add ports to firewall
sudo iptables -A INPUT -p tcp -m tcp --dport 8080 -j ACCEPT 			#McMyAdmin Port
sudo iptables -A INPUT -p tcp -m tcp --dport $MINECRAFT_PORT -j ACCEPT 			#Default Minecraft Port
/sbin/iptables-save

#setup crontab to start server when server reboots
REBOOT_COMMAND="@reboot cd ~/McMyAdmin && screen -dmS mineserver ./MCMA2_Linux_x86_64"
(crontab -l | grep $REBOOT_COMMAND) || (crontab -l 2>/dev/null; echo $REBOOT_COMMAND) | crontab -


#add Secruity permission to run AWS S3 Backup script
echo "Adding McMyAdmin permission to run S3 Backup script."
sed -i 's/Security.AllowExec=False/Security.AllowExec=True/g' ~/McMyAdmin/McMyAdmin.conf
echo "Copying backup script to scripts"




echo "============================"
echo "Install done!"
echo "Start the server by: 'cd ~/McMyAdmin && screen -dmS mineserver ./MCMA2_Linux_x86_64'"
echo "OR use 'sudo reboot' to start server"