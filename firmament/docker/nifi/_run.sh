#!/bin/bash
docker run -dt --name nifi -h nifi -p 23:22 docker-registry.parrot-les.keyw:5000/nifi:0.08.01

