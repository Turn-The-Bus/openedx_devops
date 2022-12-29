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


DB_PREFIX="ttb-india-live"

#------------------------------------------------------------------------------
# retrieve the mysql root credentials from k8s secrets. Sets the following environment variables:
#
#    MYSQL_HOST=mysql.turnthebus.org
#    MYSQL_PORT=3306
#    MYSQL_ROOT_PASSWORD=******
#    MYSQL_ROOT_USERNAME=root
#
#------------------------------------------------------------------------------
$(ksecret.sh mysql-root ttb-india-live)

echo "migrating discovery database"
mysql -h $MYSQL_HOST -u $MYSQL_ROOT_USERNAME -p$MYSQL_ROOT_PASSWORD -e "DROP DATABASE IF EXISTS ${DB_PREFIX}disc; CREATE DATABASE ${DB_PREFIX}disc CHARACTER SET utf8 COLLATE utf8_general_ci"
mysqldump --set-gtid-purged=OFF --column-statistics=0 -h $MYSQL_HOST  -u $MYSQL_ROOT_USERNAME -p$MYSQL_ROOT_PASSWORD discovery | mysql -h $MYSQL_HOST  -u $MYSQL_ROOT_USERNAME -p$MYSQL_ROOT_PASSWORD -D ${DB_PREFIX}disc

echo "migrating ecommerce database"
mysql -h $MYSQL_HOST -u $MYSQL_ROOT_USERNAME -p$MYSQL_ROOT_PASSWORD -e "DROP DATABASE IF EXISTS ${DB_PREFIX}ecom; CREATE DATABASE ${DB_PREFIX}ecom CHARACTER SET utf8 COLLATE utf8_general_ci"
mysqldump --set-gtid-purged=OFF --column-statistics=0 -h $MYSQL_HOST  -u $MYSQL_ROOT_USERNAME -p$MYSQL_ROOT_PASSWORD ecommerce | mysql -h $MYSQL_HOST  -u $MYSQL_ROOT_USERNAME -p$MYSQL_ROOT_PASSWORD -D ${DB_PREFIX}ecom

echo "migrating edxapp database"
mysql -h $MYSQL_HOST -u $MYSQL_ROOT_USERNAME -p$MYSQL_ROOT_PASSWORD -e "DROP DATABASE IF EXISTS ${DB_PREFIX}edx; CREATE DATABASE ${DB_PREFIX}edx CHARACTER SET utf8 COLLATE utf8_general_ci"
mysqldump --set-gtid-purged=OFF --column-statistics=0 -h $MYSQL_HOST -u $MYSQL_ROOT_USERNAME -p$MYSQL_ROOT_PASSWORD edxapp | mysql -h $MYSQL_HOST  -u $MYSQL_ROOT_USERNAME -p$MYSQL_ROOT_PASSWORD -D ${DB_PREFIX}edx

echo "migrating notes database"
mysql -h $MYSQL_HOST -u $MYSQL_ROOT_USERNAME -p$MYSQL_ROOT_PASSWORD -e "DROP DATABASE IF EXISTS ${DB_PREFIX}notes; CREATE DATABASE ${DB_PREFIX}notes CHARACTER SET utf8 COLLATE utf8_general_ci"
mysqldump --set-gtid-purged=OFF --column-statistics=0 -h $MYSQL_HOST -u $MYSQL_ROOT_USERNAME -p$MYSQL_ROOT_PASSWORD edx_notes_api | mysql -h $MYSQL_HOST  -u $MYSQL_ROOT_USERNAME -p$MYSQL_ROOT_PASSWORD -D ${DB_PREFIX}notes
