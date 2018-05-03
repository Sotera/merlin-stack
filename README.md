# merlin-stack

- cd merlin-stack/firmament/docker/merlin-hadoop-base/
- ./_build.sh
- output:
- Successfully tagged <aws registry ip>:5000/merlin-hadoop-base:latest
- Successfully tagged <openstack registry ip>:5000/merlin-hadoop-base:latest
- docker push <aws registry ip>:5000/hadoop-base:latest
- connect to vpn
- docker push <openstack registry ip>:5000/merlin-hadoop-base:latest
- repeat for hadoop-namenode be sure to prepend merlin-
- edit the openstack-etl.json and fill in any usernames / passwords
- DO NOT CHECK THEM IN
- f p b -i openstack-merlin.json
- f p b -i openstack-etl.json


# Notes about using an NFS mount in the stack
Docker swarm allows volumes used by services to be backed by an NFS server. Getting this to work is a little tweaky. Here are some pointers:
## Server
Most modern NFS clients will use NFS v.4 if the server provides it but Docker swarm can only use NFS v.3
This means NFS v.4 must be explicitly turned off on the NFS server. Here's how to do it on Ubuntu 16:
[Link to how to do it](https://willhaley.com/blog/ubuntu-nfs-server/)
Quick and dirty: Edit /etc/default/nfs-kernel-server so it looks like this:
```
    # Number of servers to start up
    RPCNFSDCOUNT=8

    # Runtime priority of server (see nice(1))
    RPCNFSDPRIORITY=0

    # Options for rpc.mountd.
    # If you have a port-based firewall, you might want to set up
    # a fixed port here using the --port option. For more information,
    # see rpc.mountd(8) or http://wiki.debian.org/SecuringNFS
    # To disable NFSv4 on the server, specify '--no-nfs-version 4' here
    RPCMOUNTDOPTS="--manage-gids --no-nfs-version 4"

    # Do you want to start the svcgssd daemon? It is only required for Kerberos
    # exports. Valid alternatives are "yes" and "no"; the default is "no".
    NEED_SVCGSSD=""

    # Options for rpc.svcgssd.
    RPCSVCGSSDOPTS=""

    # Options for rpc.nfsd.
    RPCNFSDOPTS="--no-nfs-version 4"
```
and reboot the computer. You might hear that bouncing the NFS service (e.g. - `/etc/init.d/nfs-kernel-server restart`) will work but
that was not my experience.

## Client
I like to test mounting an NFS volume on the Docker Machine host before attempting to deploy a stack:
```
$ docker-machine ssh <docker-machine-hostname>

[dm]$ sudo mount -t nfs -o rw,proto=tcp,async,soft,nolock 192.168.104.5:/nfs-public/merlin /mnt/merlin
```
And here's a volume block in a firmament JSON stack definition file:
```
"volumes": {
  "datavolume": {
    "driver": "local",
    "driver_opts": {
      "type": "nfs",
      "device": ":/nfs-public/merlin",
      "o": "rw,addr=192.168.104.5,proto=tcp,async,soft,nolock"
    }
  },
  "logvolume": {
    "driver": "local",
    "driver_opts": {
      "type": "nfs",
      "device": ":/nfs-public/merlin_logs",
      "o": "rw,addr=192.168.104.5,proto=tcp,async,soft,nolock"
    }
  }
}

```
## NFS
Below is a link to a tar file in an AWS/S3 bucket to the contents of the merlin-etl NFS mount. It has everything needed to build
a merlin stack to do ETL work (including a test jebBush e-mail file to extract entities from). UnTar it in the root NFS folder
(e.g. /mnt/merlin)
[https://s3.amazonaws.com/merlin-jreeme/_nfs_merlin-etl.tar.gz](https://s3.amazonaws.com/merlin-jreeme/_nfs_merlin-etl.tar.gz)
