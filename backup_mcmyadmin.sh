#!/bin/sh
#Backup your McMyAdmin configuration on a weekly or monthly basis.

#AWS Backup configurations
S3_BACKUP_URL="s3://some-s3-bucket"
STORAGE_CLASS="STANDARD"			#choose one of:  STANDARD | REDUCED_REDUNDANCY | STANDARD_IA | ONEZONE_IA


#Zip the McMyAdmin Folder
cd ~
ZIP_BACKUP_DATE=`date '+%Y-%m-%d__%H-%M-%S'`
ZIP_BACKUP_NAME="McMyAdmin-Backup-$ZIP_BACKUP_DATE.zip"
zip -r ~/$ZIP_BACKUP_NAME ~/McMyAdmin 


#AWS S3 Backup
/home/ubuntu/.local/bin/aws s3 cp --storage-class $STORAGE_CLASS ~/$ZIP_BACKUP_NAME $S3_BACKUP_URL

#cleanup
rm ~/$ZIP_BACKUP_NAME