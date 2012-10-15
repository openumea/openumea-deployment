#!/bin/bash
. $(dirname $0)/config

mkdir -p /root/backup

# Create backup script
cat > /root/backup/backup-db.sh <<EOS
#!/bin/sh

set -e

# Create filenme first, thus the date can change if we dump large amounts of data.
FILENAME="/root/backup/ckan-\`date +%Y%m%d-%H:%M\`.pg_dump"

$CKAN_VENV/bin/paster --plugin=ckan db dump $FILENAME --config=$CKAN_CONFIG
EOS

# should we archive?
if [ ! "$DB_BACKUP_S3_BUCKET" = "" ] ; then
	cat > /root/backup/backup-db.sh <<EOS

# and save it to s3
$CKAN_VENV/bin/s3put -b $DB_BACKUP_S3_BUCKET \$FILENAME

# and cleanup
rm \$FILENAME
EOS
fi

# make it fly
chmod +x /root/backup/backup-db.sh

# make it run
TMP=$(mktemp)
crontab -u root -l > $TMP
cat >> $TMP <<EOC
# m h  dom mon dow   command
*/30 * *   *   *     /root/backup/backup-db.sh
EOC
crontab -u root $TMP
rm $TMP
