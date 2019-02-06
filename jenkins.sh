#!/bin/bash

cd "$(dirname "$0")"

# Tell bower we're in CI mode
: ${CI:+true}
export CI

./build.sh
./deploy-to-paas.sh
