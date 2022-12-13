# openedx-mongo-20220912T080001.tgz

MONGODB_HOST="mongodb.master.app.turnthebus.org:27017"
S3_BUCKET="ttb-india-prod-backup"
BACKUP_KEY="20221213T171420"

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

mongo $MONGODB_HOST
use ttb_prod_edx;
db.dropDatabase();
exit

mongorestore -d ttb_prod_edx ~/backups/mongodb/mongo-dump-${BACKUP_KEY}/edxapp --host $MONGODB_HOST
