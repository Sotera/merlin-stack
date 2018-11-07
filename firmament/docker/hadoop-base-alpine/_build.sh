#!/usr/bin/env bash
docker build --rm -t 52.0.211.45:5000/merlin-hadoop-base-alpine:0.07.19 -t docker-registry.parrot.keyw:5000/merlin-hadoop-base-alpine:0.07.19 -t docker-registry.parrot-rp.keyw:5000/merlin-hadoop-base-alpine:0.07.19 -t docker-registry.parrot-les.keyw:5000/merlin-hadoop-base-alpine:0.07.19 -t docker-registry.parrot-scif.keyw:5000/merlin-hadoop-base-alpine:0.07.19 -t 10.1.70.193:5000/merlin-hadoop-base-alpine:0.07.19 .