#!/bin/bash
. $(dirname $0)/config

if [ "$CKAN_THEME" = "" ] ; then
	exit 0;
fi

# XXX: Hardcoded "theme"
if [ "$CKAN_THEME" = "openumea-theme" ] ; then
	git clone --branch master git://github.com/openumea/$CKAN_THEME.git $CKAN_ROOT/$CKAN_THEME

	# Configure us to use title and logos
	perl -pi -e 's/^ckan.site_title.*$/ckan.site_title = OpenUmea/' $CKAN_CFG
	perl -pi -e 's/^ckan.site_description.*$/ckan.site_description = Open data from the municipality of Umea/' $CKAN_CFG

	perl -pi -e 's|.*ckan.favicon =.*$|ckan.favicon = /images/icons/UmeaKommun.ico|' $CKAN_CFG
	perl -pi -e 's|.*ckan.site_logo =.*$|ckan.site_logo = /images/UmeaKommun.png|' $CKAN_CFG
	perl -pi -e 's|.*ckan.locales_offered =.*$|ckan.locales_offered = en sv|' $CKAN_CFG
fi

# to make CKAN_THEME available in perl
export CKAN_THEME

# Enable themes public and templates dirs
perl -pi -e 's|.*extra_template_paths =.*$|extra_template_paths = %(here)s/$ENV{"CKAN_THEME"}/templates|' $CKAN_CFG
perl -pi -e 's|.*extra_public_paths =.*$|extra_public_paths = %(here)s/$ENV{"CKAN_THEME"}/public|' $CKAN_CFG
