#!/usr/bin/env bash
echo "Trying to start kibana @ "`date`

kibana

echo "kibana bailed out. Attempting restart @ "`date`
exit 1
