#!/bin/bash

# Remove existing layer.zip if it exists
rm -f layer.zip

# Change to the config-layer/opt directory
cd config-layer/opt

# Create a zip file of the layer contents
zip -r ../../layer.zip .

# Return to the original directory
cd ../..

echo "Layer packaged successfully as layer.zip"