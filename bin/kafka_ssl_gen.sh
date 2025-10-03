#!/bin/bash

source "$HOME"/tdss/config.yaml  > /dev/null 2>&1


# The script will generate Certificate Authority keys and sign certificate and will import it to JKS without any prompts
# to use on the server side keystore (server.keystore.jks) and client side truststore (client.keystore.jks)

# You can add more info to the dn by updating the -dname parameter
#-dname "CN=$CERTIFICATE_CN, OU=example, O=example, L=example, S=example, C=US" \

# To inpspect jks, key and certificate:
# keytool -v -list -keystore server.keystore.jks
# openssl x509 -noout -text -in cert-signed

Dir="$HOME"/certs

if [ ! -d "$Dir" ]; then
       echo "Directory does not exist $Dir, creating directory"
       mkdir -p "$Dir"
fi



CERTIFICATE_CN=`/bin/hostname -f`
PASSWORD=changeme
PATH="$HOME/certs"

function show_usage {
  cat << EOF
  usage: auto-generate-jks.sh [options ..]
  --cert_cn Certificate Common Name.  Default: localhost
  --pass Password to use for JKS and private key. Default: changeme
EOF
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
  --cert_cn) CERTIFICATE_CN=$2; shift 2;;
  --pass) PASSWORD=$2; shift 2;;
  --help) show_usage
          exit 0
  esac
done


#echo "creating self signed certificates for use as root CAs"
#/usr/bin/openssl req -new -x509 -keyout $PATH/ca-key -out $PATH/ca-cert -days 3650 -passout pass:"$PASSWORD" -subj "/CN=$CERTIFICATE_CN"


echo "Creating Truststore"
"$JAVA_HOME"/bin/keytool -keystore $PATH/kafka.truststore.jks -alias $CERTIFICATE_CN -import -file $PATH/ca-cert -keypass "$PASSWORD" -storepass "$PASSWORD" -noprompt

echo "Creating keystore"
"$JAVA_HOME"/bin/keytool -keystore $PATH/kafka.keystore.jks -alias $CERTIFICATE_CN -validity 3650 -genkey -keyalg RSA -ext SAN=DNS:$CERTIFICATE_CN -noprompt -dname "CN=$CERTIFICATE_CN"  \
  -storepass "$PASSWORD" \
  -keypass "$PASSWORD" 

echo "Creating certificate signing request(CSR)"
"$JAVA_HOME"/bin/keytool -keystore $PATH/kafka.keystore.jks -alias $CERTIFICATE_CN -certreq -file $PATH/ca-request-zookeeper -keypass "$PASSWORD" -storepass "$PASSWORD" -noprompt

echo "Signing the certificate"
/usr/bin/openssl x509 -req -CA $PATH/ca-cert -CAkey $PATH/ca-key -in $PATH/ca-request-zookeeper -out $PATH/ca-signed -days 3650 -CAcreateserial -passin pass:"$PASSWORD"

echo "Importing the CA into Keystore"
"$JAVA_HOME"/bin/keytool -keystore $PATH/kafka.keystore.jks -alias $PATH/ca-cert -import -file $PATH/ca-cert -storepass "$PASSWORD" -noprompt  -keypass "$PASSWORD"

echo "Importing the signed certificate into Keystore"
"$JAVA_HOME"/bin/keytool -keystore $PATH/kafka.keystore.jks -alias $CERTIFICATE_CN -import -file $PATH/ca-signed -storepass "$PASSWORD" -noprompt  -keypass "$PASSWORD"




#echo "copy this script to other nodes /tmp and excute this script"

