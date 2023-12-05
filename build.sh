#!/bin/bash

set -e
echo "*** Change Directory ***"
cd "$(dirname "$0")"
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
