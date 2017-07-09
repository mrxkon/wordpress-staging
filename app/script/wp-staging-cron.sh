#!/bin/bash



# Get this file's directory path
DIR=`dirname $0`
DIR=`readlink -f $DIR`



# Attempt to hold settings in an INI file

# NAME=$(awk -F "=" '/^name=/ {print $2}' $DIR/ini.ini | tr -d ' \t\n\r')
# SURNAME=$(awk -F "=" '/^surname=/ {print $2}' $DIR/ini.ini | tr -d ' \t\n\r')
# AGE=$(awk -F "=" '/^age=/ {print $2}' $DIR/ini.ini | tr -d ' \t\n\r')

# echo -$NAME-
# echo -$SURNAME-
# echo -$AGE-



# If lock file exists previous instance is already running
LOCK_FILE=$DIR/staging.lock

if [ -f $LOCK_FILE ] ; then
    exit 1
fi

# Create a lock file in order to not run multiple times over
touch $LOCK_FILE



# Read basic settings
SETTINGS_FILE=$DIR/../inc/settings.php

BASE_URL=`cat $SETTINGS_FILE | grep \'BASE_URL\' | cut -d \' -f 4`
BASE_DIRECTORY=`cat $SETTINGS_FILE | grep \'BASE_DIRECTORY\' | cut -d \' -f 4`



# Make sure executable files are executable
chmod u+x $DIR/dist/bin/wp-staging-create.sh
chmod u+x $DIR/dist/bin/wp-staging-delete.sh
chmod u+x $DIR/dist/bin/wp-staging-php-cli.sh
chmod u+x $DIR/dist/wpcli/wp-cli.phar
chmod u+x $DIR/dist/srdb/srdb.cli.php



# The log file
LOG_FILE=`dirname $0`/../data/log/run.log

echo -- `date` -- | tee -a $LOG_FILE
echo | tee -a $LOG_FILE



# Check if any config files to create staging websites exist
if [ ! "$(ls -A $DIR/../data/new)" ]; then

    # No new staging websites to create
    echo No config files to add staging websites found | tee -a $LOG_FILE
    echo | tee -a $LOG_FILE

else

    # Iterate over config files for staging websites to create
    for FILE in $DIR/../data/new/* ; do

        FILE=`readlink -f $FILE`        

        echo Processing create file $FILE | tee -a $LOG_FILE

        # Set staging creation script parameters
        STAGING_NAME=`basename $FILE`
        SOURCE_DIRECTORY=`cat $FILE`

        echo Staging name $STAGING_NAME | tee -a $LOG_FILE
        echo Source directory $SOURCE_DIRECTORY | tee -a $LOG_FILE



        # Call the website staging creation script
        $DIR/dist/bin/wp-staging-create.sh --base-url=$BASE_URL --base-directory=$BASE_DIRECTORY --source-directory=$SOURCE_DIRECTORY --staging-name=$STAGING_NAME | tee -a $LOG_FILE

        # If staging creation script succeded move the file to the list of existing staging websites
        if [ $? -eq 0 ] ; then
            mv $FILE $DIR/../data/cur
        fi

        echo | tee -a $LOG_FILE

    done

fi



# Check if any config files to delete staging websites exist
if [ ! "$(ls -A $DIR/../data/del)" ]; then

    # No existing staging websites to delete
    echo No config files to delete staging websites found | tee -a $LOG_FILE
    echo | tee -a $LOG_FILE

else

    # Iterate over config files for staging websites to delete
    for FILE in $DIR/../data/del/* ; do

        echo Processing delete file $FILE | tee -a $LOG_FILE

        # Set staging deletion script parameters
        STAGING_NAME=`basename $FILE`
        STAGING_DIRECTORY=$BASE_DIRECTORY/$STAGING_NAME

        echo Staging directory $STAGING_DIRECTORY | tee -a $LOG_FILE



        # Call the website staging deletion script
        $DIR/dist/bin/wp-staging-delete.sh --staging-directory=$STAGING_DIRECTORY | tee -a $LOG_FILE

        # If staging deletion script succeded delete the file
        if [ $? -eq 0 ] ; then
            rm -rf $FILE
        fi

        echo | tee -a $LOG_FILE

    done

fi



# Search for WordPress websites in the fileystem
find /home -name wp-config.php -exec dirname {} \; | sort > $DIR/../data/websites.list



# Remove the lock file
rm -rf $LOCK_FILE