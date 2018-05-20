# Minecraft Ubuntu Installer

Want to spin up a Minecraft server with automated backups to Amazon AWS? Sure you can. I made this script to help spin up an instance of Minecraft on McMyAdmin and used AWS S3 as cheap offsite backup. I recommend using Ubuntu Trusty or Xenial as these are what I tested the scripts against.


## Setup Walkthrough

### 1. Configure Settings

Download the script raw from GitHub.
``` bash
wget https://raw.githubusercontent.com/kevinta893/minecraft-ubuntu-installer/master/install_minecraft_server.sh
```

Then configure the script with the intial settings in the script itself. Make sure you set the Timezone and the McMyAdmin Password.

  * **MCMYADMIN_INITIAL_PASSWORD** - The intial password to use when logging into McMyAdmin's web management console. This can be changed later.
  * **Timezone** - The timezone for your server (case sensitive), you should set this to one you are familar with so that the server backup schedules make sense. See valid timezones for Ubuntu [here](http://manpages.ubuntu.com/manpages/trusty/man3/DateTime::TimeZone::Catalog.3pm.html).
  * **S3_BACKUP_URL** - The S3 bucket URL for where your backups should go. This updates the other backup scripts automatically with your URL.
  * **MAP_BACKUP_SCHEDULE** - The 'cron' scheduled time<sup>1</sup> to backup the backups that McMyAdmin makes (default: 4:00 am daily).
  * **MCMYADMIN_BACKUP_SCHEDULE** - The 'cron' scheduled time<sup>1</sup> to backup the McMyAdmin configuration (excludes backup folder) (default: 4:30 am weekly on Wednesdays)
  
<sup>1</sup>For how to generate a time string for a custom cron schedule, see this tool [crontab.guru](https://crontab.guru/)

Settings in script:

``` bash
MCMYADMIN_INITIAL_PASSWORD=pleasechangeme
TIMEZONE=America/Edmonton
S3_BACKUP_URL="s3://some-s3-bucket"
MAP_BACKUP_SCHEDULE="0 4 * * *"
MCMYADMIN_BACKUP_SCHEDULE="30 4 * * 3"
```

### 2. Run Script
Now run the script with:
``` bash
bash install_minecraft_server.sh
```

You will be prompted several times to update McMyAdmin and to enter user credentials for Amazon Web Services (see note below for IAM tips). Once done you can start the server with 

`sudo reboot` 

or

`cd ~/McMyAdmin && screen -dmS mineserver ./MCMA2_Linux_x86_64`

Installation Done! Login to your McMyAdmin web console through port 8080 and configure the rest of your server to how you like it. I suggest adding a schedule to backup your minecraft worlds on a daily basis.



## Configuring Amazon S3 

I won't explain S3 too much. Ideally you make a new user on the IAM console on AWS and enter the user's credentials. 

Enter your credentials onto the server with:

```
aws configure
```

Once you create a new user, then create a simple backup *policy* for S3. This is one where you have limited read and write capabilities. Here are the ones that work for the 'sync' command on S3 which is all you need for this script: `ListBucket, PutObject, PutObjectAcl`

Dry run your backup scripts:

``` bash
bash backup_saves.sh
bash backup_mcmyadmin.sh
```

### Bucket Lifecycle

I also recommend setting object lifecycle policies for migrating your backups into cheaper (but infrequent access) storage. My suggestion is to shift your backup files into *STANDARD_IA* in about 30 days, and then into *GLACIER*/*DELETE* after 90. Use the S3 bucket's lifecycle rules to manage this automatically.

## Restoring Backups

Take care when restoring backups. Make sure you test the backup on a seperate instance before restoring.

### Restoring a World

1. Move the desired .mb2 world backup file into McMyAdmin/Backups
2. Login to McMyAdmin's web console
3. Select your backup file and restore the backup

Note: You need not to set the seed for the world as this is saved in McMyAdmin. Leave the preferences blank for the seed. The command is "/seed" in the Minecraft console.

### Restoring a Configuration file

Simply upload the configuration file for McMyAdmin into the same folder. That or copy the settings that you had before into the McMyAdmin web console.

