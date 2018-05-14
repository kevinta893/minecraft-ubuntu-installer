#!/bin/sh
#Backup your McMyAdmin configuration on a weekly or monthly basis.

#AWS Backup configurations
S3_BACKUP_URL="s3://some-s3-bucket"
STORAGE_CLASS="STANDARD"			#choose one of:  STANDARD | REDUCED_REDUNDANCY | STANDARD_IA | ONEZONE_IA
INCLUDE_BACKUPS_FOLDER=false                    #true to keep backups folder, false otherwise. Default false is ideal since the backup saves script already backups map saves more frequently
COMPRESSION_LEVEL=9                             #compression level from [0-9]

#Zip the McMyAdmin Folder
cd ~ || (echo "Script failed"; exit;)
ZIP_BACKUP_DATE=`date '+%Y-%m-%d__%H-%M-%S'`
ZIP_BACKUP_NAME="McMyAdmin-Backup-$ZIP_BACKUP_DATE.zip"
if [ $INCLUDE_BACKUPS_FOLDER = true ]; then
        echo "Including backups folder in McMyAdmin config backup."
        zip -$COMPRESSION_LEVEL -r ~/$ZIP_BACKUP_NAME ~/McMyAdmin
else
        echo "Excluding backups folder in McMyAdmin config backup."
        zip -$COMPRESSION_LEVEL -r ~/$ZIP_BACKUP_NAME ~/McMyAdmin -x ~/McMyAdmin/Backups/\*
fi



#AWS S3 Backup
/home/ubuntu/.local/bin/aws s3 cp --storage-class $STORAGE_CLASS ~/$ZIP_BACKUP_NAME $S3_BACKUP_URL

#cleanup
rm ~/$ZIP_BACKUP_NAME