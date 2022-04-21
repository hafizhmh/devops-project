#!/bin/bash
export sql_ip=${sql_ip}
echo ${sql_ip} > ~/sql_ip.txt
echo "$(date) 1/8" >> ~/log.txt
apt update
echo "$(date) 2/8" >> ~/log.txt
apt-get install wget -y
echo "$(date) 3/8" >> ~/log.txt
apt install python3 python3-pip -y
echo "$(date) 4/8" >> ~/log.txt
gsutil cp "gs://${bucket_name}/*" ~
echo "$(date) 5/8" >> ~/log.txt
ls -al ~ >> ~/log.txt
pip3 install -r ~/requirement.txt
echo "$(date) 6/8" >> ~/log.txt
cd ~
chmod u+x server.py
echo "$(date) 7/8" >> ~/log.txt
./server.py & >> ~/server.log
echo "$(date) 8/8" >> ~/log.txt
echo "done" >> ~/log.txt