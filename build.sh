#!/bin/bash

set -e
echo "*** Change Directory ***"
cd "$(dirname "$0")"
echo "**********************************"
echo
echo "*** Ubuntu node binary hack ***"
# Horrid hack because node binary on Ubuntu is 'nodejs' not 'node'
rm -rf node_modules/.bin/node
mkdir -p node_modules/.bin
if command -v nodejs; then
  ln -sf "$(command -v nodejs)" node_modules/.bin/node
fi
echo "**********************************"
echo
echo "*** Bundle Install ***"
bundle config set --local path .gems
bundle config set --local bin .gem-bin
bundle install --jobs 5 --retry 3
echo "**********************************"
echo
echo "*** NPM Install ***"
npm install
echo "**********************************"
echo
echo "*** Build Middleman site ***"
bundle exec middleman build --verbose
echo "**********************************"
echo
