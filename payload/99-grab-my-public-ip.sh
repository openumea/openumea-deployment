#!/bin/bash
. $(dirname $0)/config

INSTANCE_ID=$(curl --connect-timeout 1 --silent http://169.254.169.254/latest/meta-data/instance-id)

if [ -z "$INSTANCE_ID" ] ; then
	echo "Not running in ec2, no action then"
	exit 0
fi

if [ -z "$CKAN_HOSTNAME" ] ; then
	echo "No hostname defined to grab ip for"
	exit 0
fi

# what public ip are we supposed to grab?
IPADDR=$(host -t a $CKAN_HOSTNAME | perl -pi -e 's/.*has address //')


$CKAN_VENV/bin/python -c "import boto.ec2 ; ec2 = boto.ec2.connect_to_region(\"eu-west-1\") ; ec2.associate_address(\""$INSTANCE_ID"\", "\"$IPADDR"\");"
