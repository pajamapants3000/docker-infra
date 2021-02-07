#!/bin/bash

# May want to make these customizable
CERT_PW=""
DEVCERT_PATH=/aspnet/https
DEVCERT_NAME=dotnet-devcert
#

TMP_PATH=/var/tmp/localhost-dev-cert
if [ ! -d $TMP_PATH ]; then
    mkdir $TMP_PATH
fi

if [ ! -d $DEVCERT_PATH ]; then
    mkdir -p $DEVCERT_PATH
    chmod -R 755 $DEVCERT_PATH
fi

KEYFILE=$DEVCERT_NAME.key
CRTFILE=$DEVCERT_NAME.crt
PFXFILE=$DEVCERT_NAME.pfx

NSSDB_PATHS=(
    "$HOME/.pki/nssdb"
    "$HOME/snap/chromium/current/.pki/nssdb"
    "$HOME/snap/postman/current/.pki/nssdb"
)

CONF_PATH=$TMP_PATH/localhost.conf
cat >> $CONF_PATH <<EOF
[req]
prompt                  = no
default_bits            = 2048
distinguished_name      = subject
req_extensions          = req_ext
x509_extensions         = x509_ext

[subject]
commonName              = clutter-noteservice

[req_ext]
basicConstraints        = critical, CA:true
subjectAltName          = @alt_names

[x509_ext]
basicConstraints        = critical, CA:true
keyUsage                = critical, keyCertSign, cRLSign, digitalSignature,keyEncipherment
extendedKeyUsage        = critical, serverAuth
subjectAltName          = critical, @alt_names
1.3.6.1.4.1.311.84.1.1  = ASN1:UTF8String:ASP.NET Core HTTPS development certificate # Needed to get it imported by dotnet dev-certs

[alt_names]
DNS.1                   = clutter-noteservice
DNS.2                   = localhost
EOF

function configure_nssdb() {
    echo "Configuring nssdb for $1"
    certutil -d sql:$1 -D -n $DEVCERT_NAME
    certutil -d sql:$1 -A -t "CP,," -n $DEVCERT_NAME -i $TMP_PATH/$CRTFILE
}

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $TMP_PATH/$KEYFILE -out $TMP_PATH/$CRTFILE -config $CONF_PATH --passout pass:$CERT_PW
openssl pkcs12 -export -out $TMP_PATH/$PFXFILE -inkey $TMP_PATH/$KEYFILE -in $TMP_PATH/$CRTFILE --passout pass:$CERT_PW

for NSSDB in ${NSSDB_PATHS[@]}; do
    if [ -d "$NSSDB" ]; then
        configure_nssdb $NSSDB
    fi
done

echo Installing public certificate to environment
rm -vf /etc/ssl/certs/$DEVCERT_NAME.pem
cp -v $TMP_PATH/$CRTFILE "/usr/local/share/ca-certificates"
update-ca-certificates

echo Installing public and private keys for dotnet and preserve for reference and reuse
dotnet dev-certs https --clean --import $TMP_PATH/$PFXFILE -p "$CERT_PW"
cp -v $TMP_PATH/$PFXFILE $TMP_PATH/$CRTFILE $DEVCERT_PATH/
chmod -vR 644 $DEVCERT_PATH/*
rm -vR $TMP_PATH

echo "Dev cert path: $DEVCERT_PATH/$PFXFILE"
echo "Dev cert password: \"$CERT_PW\""
echo "Public cert: $DEVCERT_PATH/$CRTFILE"
