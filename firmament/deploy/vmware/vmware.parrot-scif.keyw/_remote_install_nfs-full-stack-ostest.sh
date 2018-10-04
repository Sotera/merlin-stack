#!/usr/bin/env bash
REMOTE_NFS_SERVER_ADDR=nfs.parrot-scif.keyw
REMOTE_NFS_SERVER_USER=jreeme
REMOTE_NFS_SERVER_PASSWORD=password

EXPORT_ARRAY=( "/hadoop-datavolume" "/hadoop-logvolume" "/uploads" "/postgres" "/elasticsearch0" "/elasticsearch1" "/elasticsearch2" )
EXPORT_BASE_DIR=/nfs-public/parrot-scif-ostest

echo "apt-get install -y nfs-kernel-server" > /tmp/tmp.txt
for i in "${EXPORT_ARRAY[@]}"
do
  DIR_TO_EXPORT=${EXPORT_BASE_DIR}${i}
  echo "mkdir -p ${DIR_TO_EXPORT}" >> /tmp/tmp.txt
  echo "chmod 777 ${DIR_TO_EXPORT}" >> /tmp/tmp.txt
	echo "echo '${DIR_TO_EXPORT} *(insecure,rw,sync,no_root_squash)' >> /etc/exports" >> /tmp/tmp.txt
done

echo "/etc/init.d/nfs-kernel-server restart" >> /tmp/tmp.txt

sshpass -p ${REMOTE_NFS_SERVER_PASSWORD} scp /tmp/tmp.txt ${REMOTE_NFS_SERVER_USER}@${REMOTE_NFS_SERVER_ADDR}:/tmp
sshpass -p ${REMOTE_NFS_SERVER_PASSWORD} ssh -t ${REMOTE_NFS_SERVER_USER}@${REMOTE_NFS_SERVER_ADDR} "echo ${REMOTE_NFS_SERVER_PASSWORD} | sudo -S /usr/bin/env bash /tmp/tmp.txt"
#sshpass -p ${REMOTE_NFS_SERVER_PASSWORD} ssh -t ${REMOTE_NFS_SERVER_USER}@${REMOTE_NFS_SERVER_ADDR} "rm /tmp/tmp.txt"
#rm /tmp/tmp.txt
