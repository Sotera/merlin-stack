#!/usr/bin/env bash
echo "Trying to start hadoop @ "`date`

/usr/local/bin/docker-entrypoint.sh

echo "hadoop bailed out. Attempting restart @ "`date`
exit 1
