#!/usr/bin/env bash
#docker build -t 52.0.211.45:5000/joshua:latest -t 10.1.70.193:5000/joshua:latest .
docker build --no-cache -t 52.0.211.45:5000/joshua:latest -t 10.1.70.193:5000/joshua:latest .
