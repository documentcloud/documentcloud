#!/bin/sh
echo "Running post-merge hook..."
echo "Bundling app"
bundle install
echo "post-merge hook completed"
