#!/bin/bash

# Config
MYSQLHOST=localhost         # Hostname of your MySQL server
MYSQLUSER=backup            # MySQL backup username
MYSQLPASS=password          # MySQL backup password

FTPHOST=ftpserver           # FTP hostname
FTPUSER=ftpuser             # FPT username
FTPPASS=ftppassword         # FTP password

BACKUPDIR=/local/backup/dir # directory where the local backups are stored
FTPDIR=/remote/backup/dir   # directory where the remote backups are stored

GPGPASSPHRASEFILE=/path/to/passphrase # file with you secret gpg passphrase

# Other config
MYSQL=/usr/bin/mysql
MYSQLDUMP=/usr/bin/mysqldump
BZIP2=/bin/bzip2
GPG=/usr/bin/gpg
FTPPUT=/usr/bin/ncftpput
FTPCLIENT=/usr/bin/ncftp

TIMESTAMP=$(date +"%F")

# get databases
databases=`$MYSQL -h $MYSQLHOST -u $MYSQLUSER -p$MYSQLPASS --raw --silent --skip-column-names -e "SHOW DATABASES;" | grep -Ev "(information_schema|performance_schema)"`

# backup found databases
for db in $databases; do
  DBBACKUPDIR="$BACKUPDIR/$db"
  mkdir -p $DBBACKUPDIR
  $MYSQLDUMP --opt -h $MYSQLHOST -u $MYSQLUSER $db | $BZIP2 | $GPG -c --quiet --batch --no-verbose --passphrase-file $GPGPASSPHRASEFILE > $DBBACKUPDIR/$TIMESTAMP-$db.sql.bz2.gpg

  FTPDBDIR="$FTPDIR/$db"
  $FTPPUT -u $FTPUSER -p $FTPPASS -V -m $FTPHOST $FTPDBDIR $DBBACKUPDIR/$TIMESTAMP-$db.sql.bz2.gpg > /dev/null
done

# delete old files
find "$BACKUPDIR/" -type f -mtime +14 -print0 | xargs -0 -n 1 echo | while read filename; do
  FTP_FILE=${filename/$BACKUPDIR/$FTPDIR}
  $FTPCLIENT -u $FTPUSER -p $FTPPASS $FTPHOST > /dev/null <<EOFTPDEL
  del $FTP_FILE
EOFTPDEL

    rm -f $filename
done
