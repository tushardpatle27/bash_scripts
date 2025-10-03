source ../conf/config.yaml > /dev/null 2>&1
install_dir=../libs
echo "Installing Java"
conn_ssh(){

        if [[ "$JAVA_AUTH_MECH" == "KEY" ]];then
                ssh -i "$JAVA_SERVER_KEY_LOCATION" -o StrictHostKeyChecking=no "$JAVA_SERVERS_USERNAME"@"$j" $*
        elif [[ "$JAVA_AUTH_MECH" == "PASS" ]]; then
                sshpass -p "$JAVA_SERVER_PASSWORD" "$JAVA_SERVERS_USERNAME"@"$j" $*
        elif [[ "$JAVA_AUTH_MECH" == "NIL" ]]; then
                ssh "$JAVA_SERVERS_USERNAME"@"$j" $*
        else
                echo "unexpected token type"; exit;
        fi

}
conn_ssh2(){
         if [[ "$JAVA_AUTH_MECH" == "KEY" ]];then
                scp -i "$JAVA_SERVER_KEY_LOCATION" $*
        elif [[ "$JAVA_AUTH_MECH" == "PASS" ]]; then
                sshpass -p "$JAVA_SERVER_PASSWORD" scp $*
        elif [[ "$JAVA_AUTH_MECH" == "NIL" ]]; then
                scp $*
        else
                echo "unexpected token type"; exit;
        fi
}


IFS="," read -ra servers <<< "$JAVA_SERVERS_IP"
for j in "${servers[@]}"
do
echo "$j"
conn_ssh rm -r -f "$INSTALL_DIRECTORY"/tdss/java
conn_ssh mkdir -p "$INSTALL_DIRECTORY"/tdss
conn_ssh2 "$install_dir"/jdk*.tar.gz "$JAVA_SERVERS_USERNAME"@"$j":"$INSTALL_DIRECTORY"/tdss/
conn_ssh tar -xf "$INSTALL_DIRECTORY"/tdss/jdk*.tar.gz -C"$INSTALL_DIRECTORY"/tdss/
conn_ssh mv "$INSTALL_DIRECTORY"/tdss/jdk1.8.0_351 "$INSTALL_DIRECTORY"/tdss/java
conn_ssh2 "../src/java.security" "$JAVA_SERVERS_USERNAME"@"$j":"$INSTALL_DIRECTORY"/tdss/java/jre/lib/security/
echo "Updating Conf"
echo "export JAVA_HOME="$INSTALL_DIRECTORY"/tdss/java" | conn_ssh "cat >> ~/.bashrc"
echo "export JRE_HOME="$INSTALL_DIRECTORY"/tdss/java/jre" | conn_ssh "cat >> ~/.bashrc"
echo "export PATH=\$PATH:"$INSTALL_DIRECTORY"/tdss/java/bin:"$INSTALL_DIRECTORY"/tdss/java/jre/bin" | conn_ssh "cat >> ~/.bashrc"
conn_ssh rm -r "$INSTALL_DIRECTORY"/tdss/jdk-8u351-linux-x64.tar.gz
conn_ssh source ~/.bashrc

result=$(conn_ssh "if [[ -d ~/tdss/java ]]; then echo "installed"; else echo "not installed"; fi")
if [[ $result == "not installed" ]]; then
        echo "Aborting.."
        exit;
else
        echo "Java Installed"
fi
#echo "------Java Installed------"

done
#echo "Proceeding to WebServerInstallation"
#sh ./install_tomcat.sh


