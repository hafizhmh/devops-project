#!/bin/bash
export SQL_IP=${sql_ip}
wget https://raw.githubusercontent.com/hafizhmh/devops-project/main/server.py
wget https://raw.githubusercontent.com/hafizhmh/devops-project/main/requirement.txt
apt update
apt install python3 python3-pip -y
pip3 install -r requirement.txt
chmod u+x server.py
./server.py &