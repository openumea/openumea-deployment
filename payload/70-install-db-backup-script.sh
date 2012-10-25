#!/bin/bash
. $(dirname $0)/config

# backup dir
BACKUP_DIR=/root/backup
mkdir -p $BACKUP_DIR

# Create backup script
cat > $BACKUP_DIR/backup-db.sh <<EOS
#!/bin/sh

# abort on error
set -e

# Create filenme first, thus the date can change if we dump large amounts of data.
FILENAME="$BACKUP_DIR/ckan-\`date +%Y%m%d-%H:%M\`.pg_dump"

$CKAN_VENV/bin/paster --plugin=ckan db dump \$FILENAME --config=$CKAN_CFG | grep -v 'Dumped database to:' ||:

# compress dump
gzip -9 \$FILENAME
FILENAME=\$FILENAME.gz
EOS

# should we archive?
if [ ! "$DB_BACKUP_S3_BUCKET" = "" ] ; then
	cat >> $BACKUP_DIR/backup-db.sh <<EOS

# and save it to s3
$CKAN_VENV/bin/s3put --quiet --bucket $DB_BACKUP_S3_BUCKET --prefix=$BACKUP_DIR --key_prefix=$CKAN_HOSTNAME/ \$FILENAME

# and cleanup
rm \$FILENAME
EOS
fi

# make it fly
chmod +x $BACKUP_DIR/backup-db.sh

# make it run
TMP=$(mktemp)
crontab -u root -l > $TMP
cat >> $TMP <<EOC
# m h  dom mon dow   command
*/30 * *   *   *     $BACKUP_DIR/backup-db.sh
EOC
crontab -u root $TMP
rm $TMP
