Important
=========
This is the authoritative source of how to setup ckan for OpenUmea
Everything is required to be automated and deployable by script.
This is also the disaster recovery solution.

How full deployment works
=========================

Create elastic-ip and point your dns-name to it, CKAN_HOSTNAME

Create a bucket to store ckan-files in, CKAN_STORAGE_BUCKET
Enable CORS-access to this bucket. See S3 documentation on this.

If you would like, create a bucket to store database backups, and maybe
set a life-cycle rule that removes to-old backups. DB_BACKUP_S3_BUCKET

Create a iam-role for the ckan-instance like:
{
  "Statement": [
    {
      "Action": [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObjectAcl",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucketMultipartUploads"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::CKAN_STORAGE_BUCKET",
        "arn:aws:s3:::CKAN_STORAGE_BUCKET/*",
        "arn:aws:s3:::DB_BACKUP_S3_BUCKET",
        "arn:aws:s3:::DB_BACKUP_S3_BUCKET/CKAN_HOSTNAME/*",
        "arn:aws:s3:::CREDENTIALS_BUCKET"
      ]
    },
    {
      "Action": "s3:GetObject",
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::CREDENTIALS_BUCKET/*"
    },
    {
      "Action": [
        "ec2:AssociateAddress",
        "ec2:DescribeRegions"
      ],
      "Effect": "Allow",
      "Resource": ["*"]
    }
  ]
}

RECIPENT_EMAIL_ADDRESS is your email address, where the system will send
alerts to.

SENDER_EMAIL_ADDRESS is the address that the instance will send emails
from.

If you are doing a new deployment, fill in CKAN_SYSADMIN_USER /
CKAN_SYSADMIN_PW with what you would like to start with or..

If you are restoring a system from backup, point CKAN_BACKUP to the
backup you would like to restore from.

All variables are set in payload/config, read the comments.
combined-userdata.gz is generated by make

Use the chooser dialog in "Launch new instance" and choose a Ubuntu
14.04 amd64 ebs instance, or use http://cloud.ubuntu.com/ami/ to figure
out what ami-id is corresponding. Launch it in your iam-role, and feed it
your combined-userdata.gz as userdata.

Watch your system come up for the fist time, or see your disaster
recovered.


How do I deploy it locally?
==========================
There is a make-target to create a nocloud-iso to use cloud-init for
local deployment in kvm, xen or other virtualization infrastructure.

Grab a image from http://cloud-images.ubuntu.com/trusty/current/ in a
format that fits your environment. You might need to convert the image.

Read the nodes above and fill in the relevant variables in
payload/config. Then you can generate a "nocloud"-iso containing all
the initialisation code to start a ckan-instance. This is done by
running by running "make ckan-test.iso" in the ckan-test-branch.
Attach that iso to your vm and boot it, and cloud-init will take
care of initializing and setting up your instance.

Left as a exercise for the reader is to adapt the scripts to use other
storage than S3 for filestorage.


Scripts for backup and restore
==============================

All scripts are present in this repository.

The backup script is generated by: payload/70-install-db-backup-script.sh

A restore is performed by: payload/60-restore-create-database.sh

I.e, the system takes backup when it is a running and a restore is a
redeploy of the system with a backup-file as an input.

That keeps the system configured in the same way without the need for
tinkering in order to restore the system
