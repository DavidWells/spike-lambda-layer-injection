#!/bin/bash

# Exit on error
set -e

# Configuration
LAYER_NAME="spike-lambda-layer-injection-layer"
REGION="us-west-2"

echo "Deleting Lambda layer: $LAYER_NAME"

# Get all versions of the layer
LAYER_VERSIONS=$(aws lambda list-layer-versions \
    --layer-name "$LAYER_NAME" \
    --region "$REGION" \
    --query 'LayerVersions[].Version' \
    --output text)

if [ -z "$LAYER_VERSIONS" ]; then
    echo "No versions found for layer: $LAYER_NAME"
    exit 0
fi

# Delete each version of the layer
for VERSION in $LAYER_VERSIONS; do
    echo "Deleting version $VERSION..."
    aws lambda delete-layer-version \
        --layer-name "$LAYER_NAME" \
        --version-number "$VERSION" \
        --region "$REGION"
done

echo "Layer deletion completed successfully!"
