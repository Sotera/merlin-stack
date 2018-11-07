#!/usr/bin/env bash
docker build --rm -t 52.0.211.45:5000/newman:0.07.19 -t 10.1.70.193:5000/newman:0.07.19 --no-cache .
