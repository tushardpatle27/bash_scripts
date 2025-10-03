!#/bin/bash

echo "Generating RootCA for `hostname`"
echo "Run this script in only one server and copy those geneated key and cert to other nodes /tmp"

/usr/bin/openssl req -new -x509 -keyout /home/ec2-user/certs/ca-key -out /home/ec2-user/certs/ca-cert -days 3650 -passout pass:"changeme" -subj "/CN=`hostname`"

ls -l /tmp/ca-*

echo "command to copy files to other nodes /tmp"
echo "scp -r /tmp/ca-key /tmp/ca-cert username@<hostname>:/tmp/"
