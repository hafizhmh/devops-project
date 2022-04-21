#!/bin/bash
export SQL_IP=${sql_ip}
echo $SQL_IP > ~/sql_ip.txt

apt update
apt-get install wget -y
apt install python3 python3-pip -y
wget 'https://raw.githubusercontent.com/hafizhmh/devops-project/main/server.py' -ct 0 -O ~/server.py
wget 'https://raw.githubusercontent.com/hafizhmh/devops-project/main/requirement.txt' -ct 0 -O ~/requirement.txt
ls -al ~ >> ~/log.txt
pip3 install -r ~/requirement.txt
cd ~
chmod u+x server.py
./server.py &