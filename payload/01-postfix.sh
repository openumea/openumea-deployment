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

# Configure local postfix to relay via SES
cat >> /etc/postfix/main.cf <<EOC
smtp_enforce_tls = yes
# Chrooted, and this is the one in the chroot
smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt
smtp_sasl_auth_enable = yes
smtp_sasl_tls_security_options =
sender_canonical_maps = static:$SENDER_EMAIL_ADRESS
recipient_canonical_maps = static:$RECIPENT_EMAIL_ADDRESS
EOC

if [ ! -z "$EMAIL_CREDENTIALS" ] ; then
	cat >> /etc/postfix/main.cf <<EOC
smtp_sasl_password_maps = static:$EMAIL_CREDENTIALS
EOC
fi

# reload so that the extra config bites
postfix reload

# and test it
echo test from $0 | mailx -s automatic-test root
