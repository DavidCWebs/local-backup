Local Backup Utilities: Ubuntu LAMP Stack
==========================================
These backup scripts were developed for my own needs. They are an offshoot of a wider customised server backup project that I built.

I've recently made some refinements to make the scripts more easily deployable. They're still being tested on Ubuntu 16.04, so use with caution.

The objective was to build a backup solution that is:

* Lightweight - using simple resources and minimal diskspace
* "fire and forget" - once configured, it should just run with minimal input
* Allow for simple disaster recovery - copy a few directories and reinstall a database, and a dev site is easily recovered
* Provide a "time machine" archive of incremental backups - allowing access to a timestamped copy of the target files

If you have suggestions, please feel free to contact me or create a pull request.

## Overview
There are two bash scripts in this repo:

* `backup-home-directory`: Incremental backup of the users home directory to a storage drive
* `websites-db-backup`: Incremental backup of local development sites and hot-backup of MySQL databases

Both scripts use `rsync` for the incremental backup, with the `--link-dest` option. The directory specified by --link-dest is used as a reference point, and any files in source that are unchanged relative to this reference point are hardlinked to their exisiting inode in the reference directory.

The incremental nature of the backup is very space-efficient. For example, 35 incremental daily backups of a 87G home directory uses 195G of storage space. This is made possible by hard-linking the unchanged files - which results in the whole backup being less than the sum of the parts.

## Development Websites Backup
The `websites-db-backup` script backs up all files in the Apache root directory (in my case`/var/www/html`).

It makes a hot backup of all MySQL databases, using `mysqldump`. The script loops through all databases in localhost and makes individual backup files for each database, so that a disaster recovery can be fine tuned.

The backup uses `rsync` with the `--link-dest` option to make an incremental backup - only the files which have changed since the last backup are copied to the backup destination.

This makes for a very efficient backup - though the database dump could probably be refined (pull requests welcome).

Add the script to `/usr/local/sbin` and run it under root by means of a crontab:

~~~
mv websites-db-backup /usr/local/sbin
sudo chmod u+x /usr/local/sbin/websites-db-backup

# Open crontable
sudo crontab -e

# Add the following to the crontab, save and exit
# Run backup script every day at 3 am
00 03 * * * /usr/local/sbin/websites-db-backup
~~~

## Home Directory Backup
This creates an archive of incremental backups, with the current date set as the name of the backup directory.

The home directory is hardcoded, but this could be amended to reflect the current user by using the `$USER` variable.

I got the idea for this script [here](https://blog.interlinked.org/tutorials/rsync_time_machine.html).

## How to Use
Add both scripts to `/usr/local/sbin`. Scripts should be owned by root, with 755 permissions.

Add the scripts as a cronjob to run daily:

~~~
# setup cronjob:
crontab -e

# Then enter:
0 12 * * * /usr/local/sbin/backup-home-directory; /usr/local/sbin/websites-db-backup;

# Save and exit
~~~

## Resources
I did quite a bit of research for these scripts. Here are some of the articles and resources used.

### Rsync

* [Excellent readable article on rsync](http://www.sanitarium.net/golug/rsync_backups_2010.html)
* [The 'original' incremental rsync article by Mike Rubel](http://www.mikerubel.org/computers/rsync_snapshots/)
* [Incrementally numbered backups, using rsync](https://jimmyg.org/blog/2007/incremental-backups-using-rsync.html)
* [Example bash script using rsync for local and remote backups](http://stromberg.dnsalias.org/~strombrg/Backup.remote.html)
* [rsync & cp for hardlinks](http://earlruby.org/2013/05/creating-differential-backups-with-hard-links-and-rsync/)
* [Snapshot backup  - rsync with hardlinks - with detailed examples](http://www.pointsoftware.ch/en/howto-local-and-remote-snapshot-backup-using-rsync-with-hard-links/)
* [Basic rsync examples](http://www.thegeekstuff.com/2010/09/rsync-command-examples/)
* [rsync man page - surprisingly helpful!](http://linux.die.net/man/1/rsync)
* [Time machine/rsync with good illustration of hard links](http://linux.die.net/man/1/rsync) - good sample "instant backup" script - backup every minute!
* Link Dest behaviour explanation: [answer in the rsync mailing list archive](https://lists.samba.org/archive/rsync/2010-February/024649.html)
* Link Dest and [deleting old snapshots](https://lists.samba.org/archive/rsync/2010-February/024654.html)

### MySQL
* [Database backup](http://simon-davies.name/bash/backing-up-mysql-databases)
* [mysqldump status](http://serverfault.com/questions/249853/does-mysqldump-return-a-status)
* [Create a Read-Only MySQL backup user](http://bencane.com/2011/12/12/creating-a-read-only-backup-user-for-mysqldump/)
* [MySQL backup user](http://blog.roozbehk.com/post/25580691418/mysql-user-to-backup-databases)
* [Minimum user privileges for backup using mysqldump](http://patrickv.info/wordpress/2013/04/privileges-necessary-for-mysqldump/)
* [Comprehensive listing, different user privileges](http://www.muck.net/59/mysql-minimum-permissions-for-backup-using-mysqldump)
