#!/bin/bash

set -ex

cd ./local-runner/
./local-runner-sync.sh

sleep 3s

cd ../app/
ruby ../runner.rb
