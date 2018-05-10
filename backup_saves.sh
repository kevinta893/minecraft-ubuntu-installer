#!/bin/bash
#backup your minecraft saves as often as you want (daily is cool)
S3_BACKUP_URL="s3://some-s3-bucket"
STORAGE_CLASS="STANDARD"			#choose one of:  STANDARD | REDUCED_REDUNDANCY | STANDARD_IA | ONEZONE_IA

#AWS S3 Sync folder
cd ~
/home/ubuntu/.local/bin/aws s3 sync --storage-class $STORAGE_CLASS ~/McMyAdmin/Backups $S3_BACKUP_URL
