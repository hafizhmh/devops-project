#!/bin/bash
scriptpath='/etc/profile.d/startup.sh'
export ECHO_IP=${echo_ip}

sudo cat << EOF > $scriptpath
#!/bin/bash
echo "\$(hostname) - \$(date) - $ECHO_IP" >> ~/sshres.txt
EOF

chmod u+x $scriptpath
source $scriptpath
cat $scriptpath