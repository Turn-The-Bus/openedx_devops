#!/bin/bash
#------------------------------------------------------------------------------
# written by:   Lawrence McDaniel
#               https://lawrencemcdaniel.com
#
# date:         sep-2022
#
# usage:        rename an existing database by dumping it and
#               piping the output to a restore operation using a new db name.
#------------------------------------------------------------------------------

DEST_DB_PREFIX="ttb_prod_"

#------------------------------------------------------------------------------
# retrieve the mysql root credentials from k8s secrets. Sets the following environment variables:
#
#    MYSQL_HOST=ttb-india-live.cueotjvguuws.us-east-1.rds.amazonaws.com
#    MYSQL_PORT=3306
#    MYSQL_ROOT_PASSWORD=******
#    MYSQL_ROOT_USERNAME=root
#
#------------------------------------------------------------------------------
$(ksecret.sh mysql-root ttb-india-live)

echo "migrating edxapp database"
mysql -h $MYSQL_HOST -u $MYSQL_ROOT_USERNAME -p$MYSQL_ROOT_PASSWORD -e "DROP DATABASE IF EXISTS ${DEST_DB_PREFIX}edx; CREATE DATABASE ${DEST_DB_PREFIX}edx CHARACTER SET utf8 COLLATE utf8_general_ci"
mysqldump --set-gtid-purged=OFF --column-statistics=0 -h $MYSQL_HOST -u $MYSQL_ROOT_USERNAME -p$MYSQL_ROOT_PASSWORD edxapp | mysql -h $MYSQL_HOST  -u $MYSQL_ROOT_USERNAME -p$MYSQL_ROOT_PASSWORD -D ${DEST_DB_PREFIX}edx

echo "migrating notes database"
mysql -h $MYSQL_HOST -u $MYSQL_ROOT_USERNAME -p$MYSQL_ROOT_PASSWORD -e "DROP DATABASE IF EXISTS ${DEST_DB_PREFIX}notes; CREATE DATABASE ${DEST_DB_PREFIX}notes CHARACTER SET utf8 COLLATE utf8_general_ci"
mysqldump --set-gtid-purged=OFF --column-statistics=0 -h $MYSQL_HOST -u $MYSQL_ROOT_USERNAME -p$MYSQL_ROOT_PASSWORD notes | mysql -h $MYSQL_HOST  -u $MYSQL_ROOT_USERNAME -p$MYSQL_ROOT_PASSWORD -D ${DEST_DB_PREFIX}notes

echo "migrating discovery database"
mysql -h $MYSQL_HOST -u $MYSQL_ROOT_USERNAME -p$MYSQL_ROOT_PASSWORD -e "DROP DATABASE IF EXISTS ${DEST_DB_PREFIX}disc; CREATE DATABASE ${DEST_DB_PREFIX}disc CHARACTER SET utf8 COLLATE utf8_general_ci"
mysqldump --set-gtid-purged=OFF --column-statistics=0 -h $MYSQL_HOST  -u $MYSQL_ROOT_USERNAME -p$MYSQL_ROOT_PASSWORD discovery | mysql -h $MYSQL_HOST  -u $MYSQL_ROOT_USERNAME -p$MYSQL_ROOT_PASSWORD -D ${DEST_DB_PREFIX}disc
