#!/bin/bash

#source "$HOME"/config.yaml  > /dev/null 2>&1
source ../conf/config.yaml  > /dev/null 2>&1


conn_web(){

        if [[ "$KAFKA_AUTH_MECH" == "KEY" ]];then
                ssh -i "$KAFKA_SERVER_KEY_LOCATION" -o StrictHostKeyChecking=no  "$KAFKA_SERVERS_USERNAME"@"$t" $*
        elif [[ "$KAFKA_AUTH_MECH" == "PASS" ]]; then
                sshpass -p "$KAFKA_SERVER_PASSWORD" "$KAFKA_SERVERS_USERNAME"@"$t" $*
        elif [[ "$KAFKA_AUTH_MECH" == "NIL" ]]; then
                ssh "$KAFKA_SERVERS_USERNAME"@"$t" $*
        else
                echo "unexpected token type"; exit;
        fi
}
conn_web2(){
         if [[ "$KAFKA_AUTH_MECH" == "KEY" ]];then
                scp -i "$KAFKA_SERVER_KEY_LOCATION" -r $*
        elif [[ "$KAFKA_AUTH_MECH" == "PASS" ]]; then
                sshpass -p "$KAFKA_SERVER_PASSWORD" scp $*
        elif [[ "$KAFKA_AUTH_MECH" == "NIL" ]]; then
                scp $*
        else
                echo "unexpected token type"; exit;
        fi

}


IFS="," read -ra servers <<< "$KAFKA_SERVERS_IP"
for t in "${servers[@]}"
do


echo "installing in host $t"
if [ ! -d "$INSTALL_DIRECTORY"/certs ];then
echo "Directory does not exsist, creating certs dir"
conn_web mkdir "$INSTALL_DIRECTORY"/certs
fi


conn_web source ~/.bashrc

#echo "Generating RootCA for `hostname`"
#echo "Run this script in only one server and copy those geneated key and cert to other nodes /tmp"

/usr/bin/openssl req -new -x509 -keyout $HOME/certs/ca-key -out $HOME/certs/ca-cert -days 3650 -passout pass:"changeme" -subj "/CN=`hostname`"
#conn_web2 "$INSTALL_DIRECTORY"/certs "$KAFKA_SERVER_USERNAME"@"$t":"$INSTALL_DIRECTORY"/
done

function copy_root_ca_key_and_cert (){
IFS="," read -ra servers <<< "$KAFKA_SERVERS_IP"
for t in ${servers[@]};
do
    scp -r  $HOME/certs $KAFKA_SERVER_USERNAME@$t:$HOME
    scp -r $HOME/certs $KAFKA_SERVER_USERNAME@$t:$HOME
done
}

copy_root_ca_key_and_cert
