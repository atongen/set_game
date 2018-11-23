#!/usr/bin/env bash

name=set_game
version=`cat version`
image="`whoami`/${name}:${version}"

docker build -t "$image" . && \
  docker push "$image"
