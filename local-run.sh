#!/bin/bash

set -e

cd ./test/local-runner/
./local-runner-sync.sh

sleep 3s

cd ../../
./run.sh
