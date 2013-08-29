#!/bin/bash
. $(dirname $0)/config

# deploy in the right dir
cd $CKAN_ROOT

CRONUSER="cronjob"
CRONUSER_API_KEY=`uuidgen`
CRONJOB_CONFIG_S3=s3://$CREDENTIALS_BUCKET/cronjob.cfg
CRONJOB_CONFIG=$CKAN_ROOT/cronjob.cfg

# we can't activate cronjobs without a repo!
if [ "$CRONJOBS_REPO" = "" ] ; then
	echo "No CRONJOBS_REPO defined, so not activating cronjobs"
	exit 0
fi

# Download the cronjobs
git clone git://github.com/openumea/$CRONJOBS_REPO.git $CKAN_ROOT/$CRONJOBS_REPO

if [ ! "$CRONJOB_CONFIG_S3" = "" ] ; then
	# Fetch any credentials that are needed by cronjobs:
	# The credentials are stored in a s3 bucket where only the instance-roles
	# have read-permisson so that the source-code for cronjobs and deployment
	# can be public without any credentials being public
	$CKAN_VENV/bin/fetch_file $CRONJOB_CONFIG_S3 > $CRONJOB_CONFIG
else
	# just copy the default file
	cp $CKAN_ROOT/$CRONJOBS_REPO/$(basename $CRONJOB_CONFIG) $CRONJOB_CONFIG
fi

# fist, remove any cronjob user thats restored into the db from backup.
$CKAN_VENV/bin/paster --plugin=ckan user --config=$CKAN_CFG remove $CRONUSER || :

# And then create user with known apikey and a random unknown password
$CKAN_VENV/bin/paster --plugin=ckan user --config=$CKAN_CFG add $CRONUSER apikey=$CRONUSER_API_KEY password=`pwgen 12 1` email="$RECIPENT_EMAIL_ADDRESS"

# FIXME: how to do automate this? read it from $CRONJOB_CONFIG?
$CKAN_VENV/bin/paster --plugin=ckan rights --config=$CKAN_CFG make user:$CRONUSER editor package:recreational-facilities
$CKAN_VENV/bin/paster --plugin=ckan rights --config=$CKAN_CFG make user:$CRONUSER editor package:food-inspections
$CKAN_VENV/bin/paster --plugin=ckan rights --config=$CKAN_CFG make user:$CRONUSER editor package:radon-surveys
$CKAN_VENV/bin/paster --plugin=ckan rights --config=$CKAN_CFG make user:$CRONUSER editor system:

# append the information about this ckan
cat >> $CRONJOB_CONFIG <<EOC
# Ckan credentials for $CRONUSER
[ckan]
api_key = $CRONUSER_API_KEY
api_url = http://$CKAN_HOSTNAME/api
EOC

# And activate them
TMP=$(mktemp)
crontab -u www-data -l > $TMP
cat >> $TMP <<EOC
# m h  dom mon dow   command
CRONJOB_CONFIG=$CRONJOB_CONFIG
10  5  *   *   *     run-parts $CKAN_ROOT/$CRONJOBS_REPO/
EOC
crontab -u www-data $TMP
rm $TMP
