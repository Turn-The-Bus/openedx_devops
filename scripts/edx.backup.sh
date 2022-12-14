#!/bin/bash
#---------------------------------------------------------
# written by: lawrence mcdaniel
#             https://lawrencemcdaniel.com
#             https://blog.lawrencemcdaniel.com
#
# date:       feb-2018
# modified:   jan-2021: create separate tarballs for mysql/mongo data
#
# usage:      backup MySQL and MongoDB data stores
#             combine into a single tarball, store in "backups" folders in user directory
#
# reference:  https://github.com/edx/edx-documentation/blob/master/en_us/install_operations/source/platform_releases/ginkgo.rst
#             https://docs.aws.amazon.com/documentdb/latest/developerguide/backup_restore-dump_restore_import_export_data.html
#             https://jainsaket-1994.medium.com/part-1-migration-of-aws-documentdb-to-atlas-mongodb-9c241d529039
#---------------------------------------------------------

S3_BUCKET="ttb-india-prod-backup"           # For this script to work you'll first need the following:
                                            # - create an AWS S3 Bucket
                                            # - create an AWS IAM user with programatic access and S3 Full Access privileges
                                            # - install AWS Command Line Tools in your Ubuntu EC2 instance
                                            # run aws configure to add your IAM key and secret token
#------------------------------------------------------------------------------------------------------------------------
MONGODB_HOST="app-turnthebus-mumbai-mongodb-1.clhs4wmx87b6.ap-south-1.docdb.amazonaws.com:27017"
MONGODB_PWD="SET-ME-PLEASE"      #Add your MongoDB admin password from your my-passwords.yml file in the ubuntu home folder.

MYSQL_HOST="mysql.app.turnthebus.org"
MYSQL_PWD="SET-ME-PLEASE"     #Add your MySQL root password, if one is set. Otherwise set to a null string


BACKUPS_DIRECTORY="/home/ubuntu/backups/"
WORKING_DIRECTORY="/home/ubuntu/backup-tmp/"
NUMBER_OF_BACKUPS_TO_RETAIN="10"            # Note: this only regards local storage (ie on the ubuntu server). All backups are retained in the S3 bucket forever.

#Check to see if a working folder exists. if not, create it.
if [ ! -d ${WORKING_DIRECTORY} ]; then
    mkdir ${WORKING_DIRECTORY}
    echo "created backup working folder ${WORKING_DIRECTORY}"
fi

#Check to see if anything is currently in the working folder. if so, delete it all.
if [ -f "$WORKING_DIRECTORY/*" ]; then
  sudo rm -r "$WORKING_DIRECTORY/*"
fi

#Check to see if a backups/ folder exists. if not, create it.
if [ ! -d ${BACKUPS_DIRECTORY} ]; then
    mkdir ${BACKUPS_DIRECTORY}
    echo "created backups folder ${BACKUPS_DIRECTORY}"
fi


cd ${WORKING_DIRECTORY}

# Begin Backup MySQL databases
#------------------------------------------------------------------------------------------------------------------------
echo "Backing up MySQL databases"
echo "Reading MySQL database names..."
mysql -h $MYSQL_HOST -uroot -p"$MYSQL_PWD" -ANe "SELECT schema_name FROM information_schema.schemata WHERE schema_name NOT IN ('mysql','sys','innodb','tmp','information_schema','performance_schema')" > /tmp/db.txt
DBS="--databases $(cat /tmp/db.txt)"
NOW="$(date +%Y%m%dT%H%M%S)"
SQL_FILE="mysql-data-${NOW}.sql"
echo "Dumping MySQL structures..."
mysqldump -h $MYSQL_HOST -uroot -p"$MYSQL_PWD" --add-drop-database --set-gtid-purged=OFF --column-statistics=0 ${DBS} > ${SQL_FILE}
echo "Done backing up MySQL"

#Tarball our mysql backup file
echo "Compressing MySQL backup into a single tarball archive"
tar -czf ${BACKUPS_DIRECTORY}openedx-mysql-${NOW}.tgz ${SQL_FILE}
echo "Created tarball of backup data openedx-mysql-${NOW}.tgz"
# End Backup MySQL databases
#------------------------------------------------------------------------------------------------------------------------


# Begin Backup Mongo
#------------------------------------------------------------------------------------------------------------------------
echo "Backing up MongoDB"
for db in openedx cs_comment_service_development; do
    echo "Dumping Mongo db ${db}..."
    mongodump --host="$MONGODB_HOST"  -u root -p"$MONGODB_PWD" --authenticationDatabase admin -d ${db} --out mongo-dump-${NOW}
done
echo "Done backing up MongoDB"

#Tarball all of our backup files
echo "Compressing backups into a single tarball archive"
tar -czf ${BACKUPS_DIRECTORY}openedx-mongo-${NOW}.tgz mongo-dump-${NOW}
echo "Created tarball of backup data openedx-mongo-${NOW}.tgz"
# End Backup Mongo
#------------------------------------------------------------------------------------------------------------------------


#Prune the Backups/ folder by eliminating all but the 30 most recent tarball files
echo "Pruning the local backup folder archive"
if [ -d ${BACKUPS_DIRECTORY} ]; then
  cd ${BACKUPS_DIRECTORY}
  ls -1tr | head -n -${NUMBER_OF_BACKUPS_TO_RETAIN} | xargs -d '\n' rm -f --
fi

#Remove the working folder
echo "Cleaning up"
sudo rm -r ${WORKING_DIRECTORY}

echo "Sync backup to AWS S3 backup folder"
aws s3 sync ${BACKUPS_DIRECTORY} s3://${S3_BUCKET}/backups
echo "Done!"
