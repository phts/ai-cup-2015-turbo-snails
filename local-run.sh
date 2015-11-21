#!/bin/bash

set -e

cd ./test/local-runner/
./local-runner-sync.sh

if [ -n "$1" ]
then
  sleep $1
fi

cd ../../
./run.sh
