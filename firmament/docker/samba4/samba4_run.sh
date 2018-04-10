#!/bin/sh

# User/Group creation and management
#declare -a user_array=("yarn" "dfs" "hadoop" "zoo" "zookeeper" "spark" "root")

for i in yarn hdfs hadoop zoo zookeeper spark root
do
   if [ "${i}" != "root" ]; then
	   adduser -s /sbin/nologin -h /home/samba -H -D ${i}
   fi
   smbpasswd -a $i<<EOF
$i
$i
EOF
done

mkdir -p /logs
chmod -R 777 /logs
smbd --foreground --log-stdout

while true; do sleep 60; done