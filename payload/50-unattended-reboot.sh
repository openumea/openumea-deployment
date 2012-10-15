#!/bin/bash

# if we are capable of auto-booting a new kernel (pv-grub aki)
# enable unattended rebooting
AKI=$(curl --connect-timeout 1 --silent http://169.254.169.254/latest/meta-data/kernel-id)

# http://bazaar.launchpad.net/~ubuntu-on-ec2/ubuntu-on-ec2/ec2-publishing-scripts/annotate/head:/kernels-pv-grub-hd0-V1.01.txt
# eu-west-1	aki-4feec43b	amd64	kernel	ec2-public-images-eu/pv-grub-hd0-V1.01-x86_64.gz.manifest.xml
if [ "$AKI" = "aki-4feec43b" ] ; then
	perl -pi -e 's,^//Unattended-Upgrade::Automatic-Reboot "false";$,Unattended-Upgrade::Automatic-Reboot "true";,' /etc/apt/apt.conf.d/50unattended-upgrades
fi
