#!/usr/bin/env bash

CLASSPATH_FILE=/usr/local/spark/conf/classpath.txt

echo /mnt/merlin/merlin-etl/share/libs/cubes/* | cat - $CLASSPATH_FILE > temp && mv temp $CLASSPATH_FILE
echo /mnt/merlin/merlin-etl/share/libs/common/* | cat - $CLASSPATH_FILE > temp && mv temp $CLASSPATH_FILE
echo /mnt/merlin/merlin-etl/share/libs/common/tika/* | cat - $CLASSPATH_FILE > temp && mv temp $CLASSPATH_FILE
echo /mnt/merlin/merlin-etl/share/libs/common/maxmind/* | cat - $CLASSPATH_FILE > temp && mv temp $CLASSPATH_FILE

exit
