# dropbox-archive
# Overview
For my new-to-2020 emonCMS production server, I decided to use the standard backup module written for emonCMS. The plan is to use a cron task to run the standard emoncms-export.sh script on a nightly basis. From there the idea will be to use a modified version of Paul Reed’s Dropbox-Archive script to upload the archive to Dropbox and manage the number of archives to keep. 


# Install Instructios

cd ~
git clone https://github.com/brandock/dropbox-archive
chmod +x ./dropbox-archive/backup.sh
./dropbox-archive/backup.sh

The last command will give the instructions for setting up the Dropbox token.

Notes about this.
1)	Dropbox API has changed and I can no longer create a compatible “legacy app” that works with the Antonio Frabrizi dropbox-uploader utility. So I am using the original emoncms-backup app I've had since implementing Paul Reeds dropbox-archive utility years ago, and I wrote my new script to include the ability to set a destination folder in the settings.conf. For the new 2020 emonCMS prod I used the folder /emoncms-prod. For my existing 2019 server, I continue to use /backups/ in the same app folder, as an example.
2)	I continue to need to disabled the chunked upload, which I suspect has to do with a change in the API that the script is not respecting. So that is commented out in the copy of Andrea Fabrizi's script in the /lib folder.

# Cron Task Setup
I did this as the pi user, not the superuser. It is logging to /home/pi/dropbox-archive.log

crontab -e

Add this line and save.

0 4 * * * /home/pi/dropbox-archive/backup.sh > /home/pi/dropbox-archive.log 2>&1

*Thanks to Paul Reed for all his work on this and so many things I use in my home setup.*
*Thanks to Andrea Fabrizi for his  Dropbox_uploader script.*
