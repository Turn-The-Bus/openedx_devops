#!/bin/bash
#------------------------------------------------------------------------------
# written by:   Lawrence McDaniel
#               https://lawrencemcdaniel.com
#
# date:         dec-2022
#
# usage:        download a MongoDB tarball backup from AWS S3
#               decompress the contents
#------------------------------------------------------------------------------

MONGODB_HOST="mongo"
S3_BUCKET="ttb-india-prod-backup"
BACKUP_KEY="20221214T161333"

BACKUP_TARBALL="openedx-mongo-$BACKUP_KEY.tgz"
BACKUP_FILE="mongo-dump-$BACKUP_KEY"
BACKUPS_DIRECTORY="/home/ubuntu/backups/"

#Check to see if a backups/ folder exists. if not, create it.
if [ ! -d ${BACKUPS_DIRECTORY} ]; then
    mkdir ${BACKUPS_DIRECTORY}
    echo "created backups folder ${BACKUPS_DIRECTORY}"
fi

if [ ! -f "${BACKUPS_DIRECTORY}${BACKUP_TARBALL}" ]; then
    #aws s3 cp s3://$S3_BUCKET/backups/$BACKUP_TARBALL ${BACKUPS_DIRECTORY} --recursive
    aws s3 cp s3://$S3_BUCKET/backups/$BACKUP_TARBALL ${BACKUPS_DIRECTORY}
fi

if [ ! -f "${BACKUPS_DIRECTORY}${BACKUP_FILE}" ]; then
    echo "decompressing..."
    cd ${BACKUPS_DIRECTORY}
    tar xvzf $BACKUP_TARBALL
    cd ~
fi

mongo $MONGODB_HOST
`use ttb_prod_edx`;
`db.dropDatabase()`;
exit

mongorestore -d ttb_prod_edx ${BACKUPS_DIRECTORY}mongo-dump-${BACKUP_KEY}/edxapp 
