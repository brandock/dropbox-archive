#!/bin/bash

# Script to call emonCMS standard export module for creating an archive, then sync the archives to Dropbox
# Based on Paul Reed's dropbox-archive utility https://github.com/Paul-Reed/dropbox-archive
# Adapted by Brandon Baldock November 2020

# Locate where script is installed

DIR="$(dirname $(readlink -f $0))"
cd $DIR
pwd                  // Move current working directory

# Import user settings
if [ -f ./settings.conf ]
then
    eval `egrep '^([a-zA-Z_]+)="(.*)"' ./settings.conf`
    echo "Days of archives to keep: $store"
    echo "emoncms-export.sh location: $emoncms_export_script_path"
    echo "Archives location: $backup_location"
else
    echo "ERROR: User settings file settings.conf file does not exist in $DIR"
    exit 1
    sudo service feedwriter start > /dev/null
fi

# On first run enter dropbox configuration
if [ ! -f /home/pi/.dropbox_uploader ]
then
    echo -e
    echo -e "Before using this script, it is necessary to"
    echo -e "configure your Dropbox API to allow backups"
    echo -e "to be uploaded."
    echo -e "To configure the script, run"
    echo -e "$cdir/lib/dropbox_uploader.sh"
    echo -e "and follow the prompts."
    exit 1
fi

# Run standard emonCMS backup module bash script
if [ -f $emoncms_export_script_path/emoncms-export.sh ]
then
    echo Starting backup $(date)
    $emoncms_export_script_path/emoncms-export.sh
else
    echo "ERROR: Couldn't find emoncms-export.sh script in $emoncms_export_script_path/"
    exit 1
fi

# Upload the file to Dropbox
date=$(date +"%Y-%m-%d")
if [ -f $backup_location/emoncms-backup-$date.tar.gz ]
then
    echo "Found the archive created by emoncms-export. Uploading to Dropbox."
    ./lib/dropbox_uploader.sh -sf /home/pi/.dropbox_uploader upload $backup_location/emoncms-backup-$date.tar.gz /backups/
else
    echo "ERROR: Backup file $backup_location/emoncms-backup-$date.tar.gz was not found."
    exit 1
fi

# Delete expired local archive files
cd $backup_location
echo "Removing expired local archives in $backup_location"
let keep=(24*60*$store)+30
find ./*.tar.gz -type f -mmin +$keep -exec rm {} \;

# Remove old Dropbox backups
echo "Removing archives in Dropbox /backups that no longer reside in $backup_location"
backups=($(find *.gz)) # Array of current backups

cd $DIR

dropboxfiles=($(../lib/./dropbox_uploader.sh -f /home/pi/.dropbox_uploader list /backups/ | awk 'NR!=1{ print $3 }')) # Array of Dropbox files

in_array() {
    local hay needle=$1
    shift
    for hay; do
        [[ $hay == $needle ]] && return 0
    done
    return 1
}

for i in "${dropboxfiles[@]}"
do
    in_array $i "${backups[@]}" && echo 'Keeping ' $i || ../lib/./dropbox_uploader.sh -f /home/pi/.dropbox_uploader delete /backups/$i
done

echo Completed upload $(date)
