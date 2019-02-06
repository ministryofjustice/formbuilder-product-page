#!/bin/bash

set -e

cd "$(dirname "$0")"

#export PATH=.gem-bin:node_modules/.bin:/usr/bin:$PATH

# Horrid hack because node binary on Ubuntu is 'nodejs' not 'node'
rm -rf node_modules/.bin/node
mkdir -p node_modules/.bin
if command -v nodejs; then
  ln -sf "$(command -v nodejs)" node_modules/.bin/node
fi

bundle install --path=.gems --binstubs=.gem-bin
npm install
bundle exec middleman build --verbose
