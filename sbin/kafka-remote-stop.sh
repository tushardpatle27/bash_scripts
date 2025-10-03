#!/bin/bash

source ../conf/config.yaml  > /dev/null 2>&1
install_dir=../libs
#set -e


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
IFS="," read -ra servers <<< "$KAFKA_SERVERS_IP"
for t in "${servers[@]}"
do
echo "stopping zookeeper"
conn_web sh "$INSTALL_DIRECTORY"/tdss/kafka/bin/zookeeper-server-stop.sh
sleep 3
echo "stopping kafka"
conn_web sh "$INSTALL_DIRECTORY"/tdss/kafka/bin/kafka-server-stop.sh
done

