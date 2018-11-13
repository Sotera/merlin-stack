#!/usr/bin/env bash
echo "Trying to start nifi @ "`date`

#this is just a fake entrypoint until we set up the real NiFi Service
while true;
do
  echo ">> docker-entrypoint heartbeat << @ "`date`
  sleep 60;
done

echo "nifi bailed out. Attempting restart @ "`date`
exit 1
