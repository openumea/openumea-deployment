#!/bin/bash
. $(dirname $0)/config

# backup dir
BACKUP_DIR=/root/backup
mkdir -p $BACKUP_DIR

# should we archive?
if [ "$DB_BACKUP_S3_BUCKET" = "" ] ; then
	echo "Can't clean S3-bucket from old backups without a bucket"
	exit 0
fi

# Create script to clean s3 from old backups
cat > $BACKUP_DIR/backup-cleaner-script.py <<EOS
#!$CKAN_VENV/bin/python
"""
Script to walk thru old backups in s3 and cleanout old ones.
Keep the last N backups and the ones from 00:00
"""
import boto
import re
import datetime

# variables from deploy-script
DB_BACKUP_S3_BUCKET = "$DB_BACKUP_S3_BUCKET"
CKAN_HOSTNAME = "$CKAN_HOSTNAME"
BACKUPS_TO_KEEP = 24*2*14

def main():
    """
    Main function. List content in s3 bucket and parse the date and
    time in the filename. Use that datetime to select if we sould delete
    files or not.
    """
    s3conn = boto.connect_s3()
    bucket = s3conn.get_bucket(DB_BACKUP_S3_BUCKET)
    fn_parser = re.compile('^' + CKAN_HOSTNAME + '/(?P<db>ckan|datastore)-' + \
            '(?P<year>\d{4})(?P<month>\d{2})(?P<day>\d{2})-' + \
            '(?P<hour>\d{2}):(?P<minute>\d{2})\.pg_dump\.gz$')

    filelist = {
        'ckan' : [],
        'datastore' : [],
    }

    for key in bucket.list():
        match = fn_parser.match(key.name)

        # some other file in this bucket.
        if match is None:
            continue

        db = match.group("db")

        file_date = datetime.datetime(
                int(match.group("year")),
                int(match.group("month")),
                int(match.group("day")),
                int(match.group("hour")),
                int(match.group("minute"))
                )

        filelist[db].append((file_date, key))

    # sort the list according to date
    for db in filelist.keys():
        filelist[db].sort(key=lambda obj: obj[0])

    # skip the N newest
    for db in filelist.keys():
        for file_date, key in filelist[db][:-BACKUPS_TO_KEEP]:
            if not (file_date.hour == 0 and file_date.minute == 0):
                #print "would delete : " + key.name
                key.delete()
            #else:
                #print "would keep : " + key.name


if __name__ == '__main__':
    main()
EOS

# make it fly
chmod +x $BACKUP_DIR/backup-cleaner-script.py

# make it run
TMP=$(mktemp)
crontab -u root -l > $TMP
cat >> $TMP <<EOC
# m h  dom mon dow   command
15  2  *   *   0     $BACKUP_DIR/backup-cleaner-script.py
EOC
crontab -u root $TMP
rm $TMP
