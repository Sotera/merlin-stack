## Case Study:  *Merlin stack on VMWare 6.x*
### Prerequisites
  * Server class computer running VMWare ESXi 6.x (6.7 works well) - Root level user and password will be needed
    * This machine will be referred to as the 'server' in the documentation below
  * Standard desktop or laptop on the same network as the EXSi server (running some flavor of linux with an SSH client)
    * This machine will be referred to as the 'client' in the documentation below
    * User will need *root* access (ability to sudo commands)
  * The 'client' and 'server' machines must be on a network with a DHCP server
  * _merlin.tar.gz file (this contains all needed software to stand up the Merlin stack)
  
#### Step 1 - Extract the client portion _merlin.tar.gz into the user directory of the 'client'
```bash
merlin@client:~$ tar xvf <tar-path>/_merlin.tar.gz merlin/client
merlin/client/
merlin/client/ovftool.bundle
merlin/client/vm-ova/
merlin/client/vm-ova/merlin-build-nfs-00.ova
merlin/client/_install-ovf-tool.sh
```
This will extract the client portion of the archive to the current working directory
#### Step 2 - Run the _install-ovf-tool.sh script (requires root access)
```bash
merlin@client:~$ cd merlin/client
merlin@client:~/merlin/client$ ./_install-ovf-tool.sh
[sudo] password for merlin: 
Extracting VMware Installer...done.
Installing VMware OVF Tool component for Linux 4.3.0
    Configuring...
[######################################################################] 100%
Installation was successful.
```
This will install the VMWare ovftool which will be used to create the merlin-build machine on the 'server'.
#### Step 3 - Create merlin-build machine on the 'server'
* Using a text editor open ./_create-merlin-build-vm.sh file and fill in 
```bash
merlin@client:~/merlin/client$ vi _create-merlin-build-vm.sh
  *** edit _create-merlin-build-vm.sh using comments in script as a guide ***
merlin@client:~/merlin/client$ ./_create-merlin-build-vm.sh
Opening OVA source: vm-ova/merlin-build.ova
The manifest validates
Opening VI target: vi://root@192.168.104.39:443/
Deploying to VI: vi://root@192.168.104.39:443/
Transfer Completed                    
Powering on VM: merlin-build
Task Completed                        
Completed successfully
```
#### Step 4 - Determine IP address of created VM
* Easiest way to determine IP address of 'merlin-build' machine is to use the VMWare admin website. Click the console
image and use the 'ip addr' command. Login credentials are:
  * Username: merlin
  * Password: password
  
In the example below network interface 2 (ens160) has ip address 192.168.104.22 assigned to it by the network DHCP server
```bash
Ubuntu 16.04.4 LTS merlin-build tty1

merlin-build login: merlin
Password: password
Welcome to Ubuntu 16.04.4 LTS (GNU/Linux 4.4.0-116-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

170 packages can be updated.
96 updates are security updates.

New release '18.04.1 LTS' available.
Run 'do-release-upgrade' to upgrade to it.


Last login: Fri Jan 18 11:08:05 2019
merlin@merlin-build:~$ ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: ens160: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:0c:29:2a:ce:58 brd ff:ff:ff:ff:ff:ff
    inet 192.168.104.22/20 brd 192.168.111.255 scope global ens160
       valid_lft forever preferred_lft forever
    inet6 fe80::20c:29ff:fe2a:ce58/64 scope link 
       valid_lft forever preferred_lft forever
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
    link/ether 02:42:44:0d:37:8d brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever

```
#### Step 5 - From a console on the 'client' use ssh to login to the 'merlin-build' VM (then log back out)
* The web console could also be used but working from a console on the 'client' machine is usually more pleasant
* This login is just to make sure the machine is accessible using SSH
```bash
merlin@client:~$ ssh merlin@192.168.104.22
merlin@192.168.104.22's password: password
Welcome to Ubuntu 16.04.4 LTS (GNU/Linux 4.4.0-116-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage
(etc...)
merlin@merlin-build:~$ exit
merlin@client:~$
```
