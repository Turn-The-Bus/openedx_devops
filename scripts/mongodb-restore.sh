# openedx-mongo-20220912T080001.tgz

S3_BUCKET="backups.academiacentral.org"
BACKUP_KEY="20220912T080001"

BACKUP_TARBALL="openedx-mongo-$BACKUP_KEY.tgz"
BACKUP_FILE="mongo-dump-$BACKUP_KEY"

if [ ! -f "~/backups/mongodb/$BACKUP_TARBALL" ]; then
    #aws s3 cp s3://$S3_BUCKET/backups/$BACKUP_TARBALL ~/backups/mongodb/ --recursive
    aws s3 cp s3://$S3_BUCKET/backups/$BACKUP_TARBALL ~/backups/mongodb/
fi

if [ ! -f "~/backups/mongodb/$BACKUP_FILE" ]; then
    echo "decompressing..."
    cd ~/backups/mongodb
    tar xvzf $BACKUP_TARBALL
    cd ~
fi

#mongo 'mongodb://mongodb.tmp.global-communications-academy.com:27017'
mongo
use academiacentral_staging_edx;
db.dropDatabase();
exit

mongorestore -d academiacentral_staging_edx ~/backups/mongodb/mongo-dump-${BACKUP_KEY}/edxapp --host mongodb.moocweb.com
