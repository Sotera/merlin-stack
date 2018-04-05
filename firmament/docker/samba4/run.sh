#!/bin/sh

# User/Group creation and management
#declare -a user_array=("yarn" "dfs" "hadoop" "zoo" "zookeeper" "spark" "root")

for i in yarn hdfs hadoop zoo zookeeper spark root
do
   adduser -s /sbin/nologin -h /home/samba -H -D ${i}
   smbpasswd -a $i<<EOF
$i
$i
EOF
done

chmod -R 777 /logs
smbd --foreground --log-stdout
