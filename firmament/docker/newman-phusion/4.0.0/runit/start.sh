#!/usr/bin/env bash
echo "Trying to start newman @ "`date`

/srv/software/newman/wsgi_server.py

echo "newman bailed out. Attempting restart @ "`date`
exit 1
