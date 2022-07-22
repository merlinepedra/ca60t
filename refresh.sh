# Where am I?
SCRIPT_DIR=$( dirname $0; );

LIGHTY_USER="www-data";

# Copy docs
cp -r ${SCRIPT_DIR}/docs/* /webroot/var/www/html;

# Perms for docs
chown -R ${LIGHTY_USER}:${LIGHTY_USER} /webroot/var/www;
chmod -R 0500 /webroot/var/www;
