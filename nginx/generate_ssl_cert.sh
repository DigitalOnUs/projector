#!/bin/bash

C=MX
ST=NL
L=MTY
O=DOU
OU=INN
CN=bla

KEYDIR=/etc/pki/tls/private
CERTDIR=/etc/pki/tls/certs
SSL_KEY=$KEYDIR/localhost.key
SSL_CERT=$CERTDIR/localhost.crt
SSL_CSR=$CERTDIR/localhost.csr

mkdir -p $KEYDIR $CERTDIR

# Create new key
openssl genrsa 2048 >$SSL_KEY
chmod go-rwx $SSL_KEY

umask 77

# Create Certitifcate Signing Request
openssl req -new -sha256 -key $SSL_KEY -out $SSL_CSR -subj "/C=$C/ST=$ST/L=$L/O=$O/OU=$OU/CN=$CN"

# Create self-signed certificate
openssl req -key $SSL_KEY -in $SSL_CSR -x509 -days 3650 -out $SSL_CERT
