Installation of Software Components (KAFKA):
Download the following package which consists of the libraries and scripts to install the software required for Product Deployment.
http://tookitaki-artifacts.tookitaki.com/artifactory/Software-packages/v5/softcomponents_kafka_v5.0.2.tar.gz
The following are the dirs in the main directory of the above-downloaded file: 
bin (Main installation scripts)
conf (Configuration files)
lib (Softwares dir)
sbin (Start and stop scripts of services)
src (Templete files)
Enter the required environmental variables in the conf/config.yaml file:
INSTALL_DIRECTORY=  /local/1/  (Base directory in which installation would be performed)
Installation Properties




After adding the required details in the conf/config.yaml file, execute the following files from the bin in the same order:
sh install_java.sh
sh RootCAgen.sh
sh install_kafka.sh
Execution:
This script is designed with SSL (makes sure SSL certs are replaced in config.yaml before executing the script from bin).
 
To generate SSL certs Manually  please follow the below document.
KAFKA SSL SETUP GUIDE
 

Steps to generate certs:

Generate RootCA
openssl req -new -x509 -keyout ca-key -out ca-cert -days 3650
copy the above ca-key and ca-cert to all three servers.
Repeat the below steps on all 3 servers. make sure to replace server-fqdn with your server's fully qualified domain name
Note : (First name and last name should be individual server hostnames (hostname -f) and the common name also should be individual server hostnames)
Create Truststore
keytool -keystore kafka.truststore.jks -alias server-fqdn -import -file ca-cert
Create Keystore
 keytool -keystore kafka.keystore.jks -alias server-fqdn -validity 3650 -genkey -keyalg RSA -ext SAN=DNS: server-fqdn
Create certificate signing request
 keytool -keystore kafka.keystore.jks -alias server-fqdn -certreq -file ca-request-zookeeper
Sign the certificate
 openssl x509 -req -CA ca-cert -CAkey ca-key -in ca-request-out ca-signed -days 3650 -CAcreateserial
Import the CA into Keystore
 keytool -keystore kafka.keystore.jks -alias ca-cert -import -file ca-cert
Import the signed certificate into Keystore
 keytool -keystore kafka.keystore.jks -alias server-fqdn -import -file ca-signed

This script (install_kafka.sh) will install three zookeepers and three kafka brokers on three nodes.



Note - 

add this files in libs from apache website archives - 

/softcomponents_kafka/libs

tusharpatle@ip-192-168-1-4 libs % du -s -h *
4.0K	RootCAgen.sh
143M	jdk-8u351-linux-x64.tar.gz
101M	kafka_2.13-3.4.0.tgz
4.0K	kafka_ssl_gen.sh
 28K	libaio-0.3.109-13.el7.x86_64.rpm
