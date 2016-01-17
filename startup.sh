#!/bin/sh

CERTDIR=/certs
CONFDIR=/conf

# Data mount
if [ "$CFG_NFS_MOUNT" != "" ]; then
   echo Mounting $CFG_NFS_MOUNT onto /data via NFS
   echo This will fail if container was not started with --privileged
   mount -v -t nfs "$CFG_NFS_MOUNT" /data
fi

# Certificates to copy to location
cd $CERTDIR
if [ "$CFG_CERT" != "" -a "$CFG_CERT_FILE" != "" ];then
   echo Loading certificate into file $CFG_CERT_FILE
   echo "$CFG_CERT" | sed 's/\\n/\n/g' > $CERTDIR/$CFG_CERT_FILE
fi
if [ "$CFG_KEY" != "" -a "$CFG_KEY_FILE" != "" ];then
   echo Loading key into file $CFG_KEY_FILE
   echo "$CFG_KEY" | sed 's/\\n/\n/g' > $CERTDIR/$CFG_KEY_FILE
fi
if [ "$CFG_CERT_FILE" != "" -a "$CFG_KEY_FILE" != "" -a "$CFG_DOMAIN" != "" -a ! -f "$CFG_CERT_FILE" ];then
    echo Creating self-signed certificates for domain $CFG_DOMAIN
    openssl req -x509 -newkey rsa:2048 -keyout "$CERTDIR/$CFG_KEY_FILE" -out "$CERTDIR/$CFG_CERT_FILE" -days 365 -nodes -subj "/CN=$CFG_DOMAIN"
fi

# Configuration file content
cd $CONFDIR
if [ "$CFG_CONFIG_URL" != "" -a "$CFG_CONFIG_FILE" != "" ];then
   echo Using URL to retrieve $CFG_CONFIG_FILE
   if [ "$CFG_USER" != "" ]; then
       echo Using authenticated user $CFG_USER
       AUTH=" --user='$CFG_USER' --password='$CFG_PASS' "
   else
       AUTH=""
   fi
   wget -nv -nc --no-check-certificate  $AUTH --output-document="$CONFDIR/$CFG_CONFIG_FILE" "$CFG_CONFIG_URL"
fi
if [ "$CFG_CONFIG" != "" -a "$CFG_CONFIG_FILE" != "" ];then
   echo Using passed configuration file for $CFG_CONFIG_FILE
   echo "$CFG_CONFIG" | sed 's/\\n/\n/g' > $CONFDIR/$CFG_CONFIG_FILE
fi

# Test mode
if [ "$CFG_TEST" != "" ]; then
    echo TEST MODE
    ls -l $CONFDIR $CERTDIR
    echo Config file contents
    cat $CONFDIR/$CFG_CONFIG_FILE
fi

exit 0
