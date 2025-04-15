#!/bin/bash

# Exit on error
set -e

# Configuration
LAYER_NAME="spike-lambda-layer-injection-layer"
LAYER_DESCRIPTION="Layer for spike-lambda-layer-injection project"
COMPATIBLE_RUNTIMES="nodejs22.x"
REGION="us-west-2"

echo "Publishing Lambda layer: $LAYER_NAME"

# Check if layer.zip exists
if [ ! -f "layer.zip" ]; then
    echo "Error: layer.zip not found. Please run package-layer.sh first."
    exit 1
fi

# Create the layer
LAYER_VERSION=$(aws lambda publish-layer-version \
    --layer-name "$LAYER_NAME" \
    --description "$LAYER_DESCRIPTION" \
    --compatible-runtimes "$COMPATIBLE_RUNTIMES" \
    --zip-file fileb://layer.zip \
    --region "$REGION" \
    --query 'Version' \
    --output text)

if [ $? -eq 0 ]; then
    echo "Layer published successfully!"
    echo "Layer ARN: arn:aws:lambda:$REGION:$(aws sts get-caller-identity --query 'Account' --output text):layer:$LAYER_NAME:$LAYER_VERSION"
else
    echo "Error publishing layer"
    exit 1
fi 