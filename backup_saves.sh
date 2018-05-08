#!/bin/bash
#backup your minecraft saves as often as you want (daily is cool)
S3_BACKUP_URL="s3://some-s3-bucket"


#AWS S3 Sync folder
cd ~
/home/ubuntu/.local/bin/aws s3 sync ~/McMyAdmin/Backups $S3_BACKUP_URL
