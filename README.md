#merlin-stack

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
 
