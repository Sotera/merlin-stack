#!/bin/bash
docker run -dt --name nifi -h nifi -p 2222:22 docker-registry.parrot-scif.keyw:5000/nifi:0.08.02

