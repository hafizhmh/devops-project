#!/bin/bash
export SQL_IP=${sql_ip}
echo "ok" >> ~/log.txt
echo $SQL_IP > ~/sql_ip.txt
echo $SQL_IP >> ~/log.txt
echo "ok IP" >> ~/log.txt

apt update
apt-get install wget -y
apt install python3 python3-pip -y
echo "ok install" >> ~/log.txt
wget 'https://raw.githubusercontent.com/hafizhmh/devops-project/main/server.py' -ct 0 -O ~/server.py
wget 'https://raw.githubusercontent.com/hafizhmh/devops-project/main/requirement.txt' -ct 0 -O ~/requirement.txt
echo "ok wget" >> ~/log.txt
ls -al ~ >> ~/log.txt
pip3 install -r ~/requirement.txt
echo "ok pip" >> ~/log.txt
cd ~
echo "cd" >> ~/log.txt
ls -al >> ~/log.txt
chmod u+x server.py
echo "chmod" >> ~/log.txt
ls -al ~ >> ~/log.txt
./server.py &
echo "server done" >> ~/log.txt