#!/bin/bash
. $(dirname $0)/config

#debconf setup postfix
debconf-set-selections <<EOC
postfix postfix/mailname string $EXTERNAL_HOSTNAME
postfix postfix/main_mailer_type select Internet Site
EOC

if [ ! -z "$RELAY_HOST" ] ; then
	debconf-set-selections <<EOC
postfix postfix/relayhost string $RELAY_HOST
EOC
fi

apt-get install -y postfix bsd-mailx

# Configure local postfix to force email addresses
if [ ! -z "$SENDER_EMAIL_ADDRESS" ] ; then
	cat >> /etc/postfix/main.cf <<EOC
sender_canonical_maps = static:$SENDER_EMAIL_ADDRESS
EOC
fi

if [ ! -z "$RECIPENT_EMAIL_ADDRESS" ] ; then
	cat >> /etc/postfix/main.cf <<EOC
recipient_canonical_maps = static:$RECIPENT_EMAIL_ADDRESS
EOC
fi

if [ ! -z "$EMAIL_CREDENTIALS" ] ; then
	cat >> /etc/postfix/main.cf <<EOC
# Chrooted, and this is the one in the chroot
smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt
smtp_enforce_tls = yes
smtp_sasl_auth_enable = yes
smtp_sasl_tls_security_options =
smtp_sasl_password_maps = static:$EMAIL_CREDENTIALS
EOC
fi

# reload so that the extra config bites
postfix reload

# and test it
echo test from $0 | mailx -s automatic-test root
