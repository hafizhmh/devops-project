#!/bin/bash
scriptpath='/etc/profile.d/startup-client.sh'
# scriptpath='/root/startup-client.sh'
export ECHO_IP=${echo_ip}

echo ForceCommand $scriptpath >> /etc/ssh/sshd_config.d/postlogin.sh

sudo cat << EOF > $scriptpath
#!/bin/bash
echo "\$(hostname) - \$(date) - $ECHO_IP" >> ~/sshres.txt
curl -X POST http://$ECHO_IP/hostname_count \
    -H 'Content-Type: application/json' \
    -d '{"hostname":"$(hostname)"}' >> ~/curlres.txt &
echo "\n" >> ~/curlsres.txt
EOF

chmod u+x $scriptpath
source $scriptpath