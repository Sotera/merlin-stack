#!/bin/bash
docker run -dt --name newman -h newman -p 5000:5000 docker-registry.parrot-les.keyw:5000/newman:0.08.01

