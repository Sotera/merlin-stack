#!/bin/bash
docker run -dt --name nifi -h nifi -p 23:22 192.168.99.100:5000/nifi:0.08.05

