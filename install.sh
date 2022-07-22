# Where am I?
SCRIPT_DIR=$( dirname $0; );

# Secret
SECRET=${SCRIPT_DIR}/security/hs_ed25519_secret_key;

# Create filenames
SERVICE_NAME=$( cat /proc/sys/kernel/random/uuid; );
SERVICE_DIR=/var/lib/tor/${SERVICE_NAME};
SERVICE_SECRET=${SERVICE_DIR}/hs_ed25519_secret_key;
USOCK=/var/run/${SERVICE_NAME}.sock;
TORRC=/etc/tor/torrc;
LIGHTY_CONF=/etc/lighttpd/lighttpd.conf;
OBFS4EXEC=$( which obfs4proxy; )

TOR_USER="debian-tor";
LIGHTY_USER="www-data";

# Copy secret key
mkdir ${SERVICE_DIR};
cat ${SECRET} > ${SERVICE_SECRET};
chown -R ${TOR_USER}:${TOR_USER} ${SERVICE_DIR};
chmod -R 0700 ${SERVICE_DIR};	

# Config Tor
echo "HiddenServiceDir "${SERVICE_DIR}"" >> ${TORRC};
echo "HiddenServicePort 80 unix:"${USOCK}"" >> ${TORRC};

# Restart Tor
service tor stop;
service tor start;

# Jail lighttpd
mkdir -p /webroot/{tmp,etc};
mkdir -p /webroot/var/{log/lighttpd,tmp/lighttpd/cache/compress,www/html,run};
mkdir -p /webroot/home/lighttpd;
chown -R root:${LIGHTY_USER} /webroot;
chmod -R 0750 /webroot;
chmod 0770 /webroot/tmp;
chown ${LIGHTY_USER}:${LIGHTY_USER} /webroot/var/log/lighttpd;
chown ${LIGHTY_USER}:${LIGHTY_USER} /webroot/var/tmp/lighttpd/cache/compress;
chown ${LIGHTY_USER}:${LIGHTY_USER} /webroot/home/lighttpd;
chmod 0700 /webroot/home/lighttpd;

# Config lighttpd
echo 'server.chroot = "/webroot"' >> ${LIGHTY_CONF};
echo 'server.name = "CA60T"' >> ${LIGHTY_CONF};
echo 'server.tag = "starless"' >> ${LIGHTY_CONF};
echo 'server.bind = "'${USOCK}'"' >> ${LIGHTY_CONF};
echo 'server.socket-perms = "0770"' >> ${LIGHTY_CONF};

# Restart lighttpd
service lighttpd stop;
service lighttpd start;

# Wait until socket is created
while [ ! -S ${USOCK} ]; do sleep 1; done;
sleep 1;

# Owners for socket
chown www-data:debian-tor ${USOCK};

# Copy docs
bash ${SCRIPT_DIR}/refresh.sh;
