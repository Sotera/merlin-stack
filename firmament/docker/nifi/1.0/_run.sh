#!/bin/bash
docker run -dt --name nifi -h nifi -p 2222:22 10.1.70.193:5000/nifi:0.08.05

