# mysql_backup.sh

This is a script I use for creating backups for my servers MySQL databases and store the backups on a remote server

## Features:

* one directory per database (so you can restore a single DB easily)
* one dump file per day
* use mysqldump for easy restore
* compress backups (bzip2)
* encrypt backups (gpg)
* copy backups to a remote FTP server
* keep backups for 14 days

## Required Dependencies

* mysql-client (or compatible, tested with percona)
* bzip2
* gnupg
* ncftp

on liner for debian based distributions:  
`apt-get install mysql-client bzip2 gnupg ncftp`

## ToDo

* options for / switch from ftp to sftp/scp/whatever
* support other compressions
* support other encryption methods