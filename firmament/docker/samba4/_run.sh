#!/usr/bin/env bash
docker run -dt -v $PWD/smb.conf:/etc/samba/smb.conf -p 445:445 --name merlin-samba4 --restart=always 52.0.211.45:5000/merlin-samba4
