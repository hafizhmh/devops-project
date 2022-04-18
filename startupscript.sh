#!/bin/bash
scriptpath='/etc/profile.d/startup.sh'
sudo cat << EOF > $scriptpath
#!/bin/bash
echo $(date) >> ~/sshres.txt
EOF
chmod u+x $scriptpath
source $scriptpath