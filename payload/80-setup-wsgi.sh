#!/bin/bash
. $(dirname $0)/config

cd $CKAN_ROOT

# Create a wsgi entrypoint
cat >> ckan.wsgi <<EOP
#!/usr/bin/env python

import os
instance_dir = '$CKAN_ROOT'
config_file = None
config_filepath = '$CKAN_CFG'
virtualenv = '$CKAN_VENV'
activate_this = os.path.join(virtualenv, 'bin', 'activate_this.py')
execfile(activate_this, dict(__file__=activate_this))

os.chdir(instance_dir)

from paste.deploy import loadapp
if not config_filepath and config_file:
	config_filepath = os.path.join(instance_dir, config_file)

from paste.script.util.logging_config import fileConfig
fileConfig(config_filepath)
application = loadapp('config:%s' % config_filepath)
EOP

cat >> /etc/apache2/sites-available/ckan <<EOC
<VirtualHost *:80>
	ServerName $CKAN_HOSTNAME
	ServerAdmin $RECIPENT_EMAIL_ADDRESS

	WSGIScriptAlias / $CKAN_ROOT/ckan.wsgi

	# pass authorization info on (needed for rest api)
	WSGIPassAuthorization On
</VirtualHost>
EOC

# disable default site and enable ckan
a2dissite default
a2ensite ckan

# reload config to have it bite
/etc/init.d/apache2 reload
