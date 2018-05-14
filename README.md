# Minecraft Ubuntu Installer

Want to spin up a Minecraft server with automated backups to Amazon AWS? Sure heck you can. I made this script to help spin up an instance of Minecraft on McMyAdmin and used AWS S3/Glacier as cheap offsite backup. I recommend using Ubuntu Trusty or Xenial as these are what I test the scripts against.

Note: Script is still under developement

# Setup

## Configure Settings

Download the script raw from GitHub.
``` bash
wget https://raw.githubusercontent.com/kevinta893/minecraft-ubuntu-installer/master/install_minecraft_server.sh
```

Then configure the script with the intial settings in the script itself. Make sure you set the Timezone and the McMyAdmin Password. See valid timezones for Ubuntu [here](http://manpages.ubuntu.com/manpages/trusty/man3/DateTime::TimeZone::Catalog.3pm.html).

``` bash
MCMYADMIN_INITIAL_PASSWORD=pleasechangeme
TIMEZONE=America/Edmonton
```

## Configure Amazon S3 (optional)

I won't explain too much about S3 here. This step is optional and shouldn't really have an impact if you did not setup AWS. Once you make an S3 Bucket, simply configure the **S3_BACKUP_URL** variable in the install script
the scripts will automatically store copies of your McMyAdmin backup folders and also backup the entire McMyAdmin folder.

``` bash
S3_BACKUP_URL="s3://some-s3-bucket"
```

## Install
Now run the script with:
``` bash
bash install_minecraft_server.sh
```

You'll be prompted several times to enter AWS details and whether you want to update McMyAdmin.

Done! Enjoy your Minecraft server with automated backups.

# Restoring Backups

Take care when restoring backups. Make sure you test the backup on a seperate instance before restoring.

(coming soon...)
