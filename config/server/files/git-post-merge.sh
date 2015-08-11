#!/bin/sh

echo "Running post-merge hook..."
echo "Bundling app"
./bin/bundle install
echo "post-merge hook completed"
