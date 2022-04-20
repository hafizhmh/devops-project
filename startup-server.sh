#!/bin/bash
touch ~/ok.txt
export SQL_IP=${sql_ip}
echo "ok" > ~/ok.txt
echo $SQL_IP > ~/ok.txt
wget https://raw.githubusercontent.com/hafizhmh/devops-project/main/server.py
wget https://raw.githubusercontent.com/hafizhmh/devops-project/main/requirement.txt
echo "ok wget" > ~/ok.txt
apt update
apt install python3 python3-pip -y
pip3 install -r requirement.txt
echo "ok install" > ~/ok.txt
chmod u+x server.py
./server.py &