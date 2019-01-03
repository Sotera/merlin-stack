#!/bin/bash
docker run -dt --name newman -h newman -p 2222:22 -p 5000:5000 192.168.99.100:5000/newman:0.08.05

