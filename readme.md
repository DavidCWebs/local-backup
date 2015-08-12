#Backup Local Website Files & Databases
Backs up all files in the Apache root directory (e.g. `/var/www`).

Makes a hot backup of all MySQL databases - loops through databases individually, do that a rdisaster recovery can be fine tuned.

##Incremental
The backup uses `rsync` with the `--link-dest` option to make an incremental backup - only the files which have changed since the last backup are copied to the backup destination.

This makes for a very efficient backup - though the datbase dump could probably be refined.

##Utilities
Uses `mysqldump` for the database backup, and `rsync` for the incremental backup.
