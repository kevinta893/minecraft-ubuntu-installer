#!/bin/sh
#intended for Ubuntu installs


#Setup your intial settings here first!
MCMYADMIN_INITIAL_PASSWORD=pleasechangeme
TIMEZONE=America/Edmonton
MINECRAFT_PORT=25565				#25565 is the default minecraft port


#AWS s3 link, you can set this up in the backup scripts individually if not set
S3_BACKUP_URL="s3://some-s3-bucket"

#backup schedule for CRON
#Setup your backup schedules using this tool here: https://crontab.guru/
MAP_BACKUP_SCHEDULE="0 4 * * *"
MCMYADMIN_BACKUP_SCHEDULE="30 4 * * 3"


#=======================
#General setup

#update system first
sudo apt-get -y update

#setup timezone for your server. To see avaliable timezones on linux, see "ls /usr/share/zoneinfo" and copy the appropriate timezone file
sudo cp /usr/share/zoneinfo/$TIMEZONE /etc/localtime
w

#Other tools
sudo apt-get -y install unzip
sudo apt-get -y install zip
sudo apt-get -y install nano
sudo apt-get -y install wget
sudo apt-get -y install cron

#install Java 8 runtime
sudo apt-get -y install openjdk-8-jre



#grab backup scripts
cd ~
wget https://raw.githubusercontent.com/kevinta893/minecraft-ubuntu-installer/master/backup_mcmyadmin.sh
wget https://raw.githubusercontent.com/kevinta893/minecraft-ubuntu-installer/master/backup_saves.sh
chmod +x backup_mcmyadmin.sh
chmod +x backup_saves.sh


#Apply s3 backup URL to scripts
sed -i 's|S3_BACKUP_URL=\"s3://some-s3-bucket\"|S3_BACKUP_URL="$S3_BACKUP_URL"|g' backup_mcmyadmin.sh
sed -i 's|S3_BACKUP_URL=\"s3://some-s3-bucket\"|S3_BACKUP_URL="$S3_BACKUP_URL"|g' backup_saves.sh


#setup crontab for scheduled backups
MCMYADMIN_BACKUP="$MCMYADMIN_BACKUP_SCHEDULE bash ~/backup_mcmyadmin.sh"
GREP_ESCAPED=`echo "$MCMYADMIN_BACKUP" | sed 's|\*|\\\*|g'`
(crontab -l | grep "$GREP_ESCAPED") || (crontab -l 2>/dev/null; echo "$MCMYADMIN_BACKUP") | crontab -
MAP_BACKUP="$MAP_BACKUP_SCHEDULE bash ~/backup_saves.sh"
GREP_ESCAPED=`echo "$MAP_BACKUP" | sed 's|\*|\\\*|g'`
(crontab -l | grep "$GREP_ESCAPED") || (crontab -l 2>/dev/null; echo "$MAP_BACKUP") | crontab -



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
echo "Setup your AWS access keys now."
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


#Ask the user to accept EULA
echo "You will need to accept the Minecraft EULA to run the server, see https://account.mojang.com/documents/minecraft_eula"
CURRENT_DATE=`date -u '+%a %b %d %T UTC %Y'`
while true; do
    read -p "Do you accept the Minecraft EULA? [y/n]" yn
    case $yn in
        [Yy]* ) mkdir ~/McMyAdmin/Minecraft/; printf "#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://account.mojang.com/documents/minecraft_eula).\n$CURRENT_DATE\neula=true" > ~/McMyAdmin/Minecraft/eula.txt; break;;
        [Nn]* ) echo "You can accept this EULA later in McMyAdmin/Minecraft/eula.txt after you start the Minecraft server"; break;;
        * ) echo "Please answer yes or no.";;
    esac
done


#Add ports to firewall
echo "Adding ports to firewall"
sudo iptables -A INPUT -p tcp -m tcp --dport 8080 -j ACCEPT 			#McMyAdmin Port
sudo iptables -A INPUT -p tcp -m tcp --dport $MINECRAFT_PORT -j ACCEPT 			#Default Minecraft Port
/sbin/iptables-save


#setup crontab to start server when server reboots
echo "Adding  command to launch server on startup."
REBOOT_COMMAND="@reboot cd ~/McMyAdmin && screen -dmS mineserver ~/McMyAdmin/MCMA2_Linux_x86_64"
(crontab -l | grep "$REBOOT_COMMAND") || (crontab -l 2>/dev/null; echo "$REBOOT_COMMAND") | crontab -



echo "============================"
echo "Install done!"
echo "You may remove the installation script now."
echo "Start the server by: '$REBOOT_COMMAND'"
echo "OR use 'sudo reboot' and the server will boot on restart"