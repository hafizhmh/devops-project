#!/bin/bash
scriptpath='/etc/profile.d/startup-client.sh'
# scriptpath='/root/startup-client.sh'
export ALPHA_SERVER_IP=${alpha_server_ip}

echo ForceCommand $scriptpath >> /etc/ssh/sshd_config.d/postlogin.sh

sudo cat << EOF > $scriptpath
#!/bin/bash
echo "\$(hostname) - \$(date) - $ALPHA_SERVER_IP" >> ~/sshres.txt
curl -sX POST http://$ALPHA_SERVER_IP/hostname_count \
    -H 'Content-Type: application/json' \
    -d '{"hostname":"$(hostname)"}' &>>~/sshres.txt &
EOF

chmod u+x $scriptpath
source /etc/ssh/sshd_config