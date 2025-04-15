#!/bin/bash

# Exit on error
set -e

# Disable AWS CLI pager
export AWS_PAGER=""

# Configuration
LAYER_NAME="spike-lambda-layer-injection-layer"
REGION="us-west-2"
FUNCTIONS=(
    "spike-lambda-layer-injection-dev-hello"
    "spike-lambda-layer-injection-dev-goodbye"
)

echo "Detaching Lambda layer from functions..."

# Get the latest layer version
LAYER_VERSION=$(aws lambda list-layer-versions \
    --layer-name "$LAYER_NAME" \
    --region "$REGION" \
    --query 'LayerVersions[0].Version' \
    --output text)

if [ -z "$LAYER_VERSION" ]; then
    echo "Error: Could not find layer version for $LAYER_NAME"
    exit 1
fi

# Get the layer ARN
LAYER_ARN="arn:aws:lambda:$REGION:$(aws sts get-caller-identity --query 'Account' --output text):layer:$LAYER_NAME:$LAYER_VERSION"

echo "Using layer ARN: $LAYER_ARN"

# Detach layer from each function
for FUNCTION in "${FUNCTIONS[@]}"; do
    echo "Detaching layer from function: $FUNCTION"
    
    # Get current configuration
    CURRENT_CONFIG=$(aws lambda get-function-configuration \
        --function-name "$FUNCTION" \
        --region "$REGION")
    
    # Get current layers excluding our layer
    CURRENT_LAYERS=$(echo "$CURRENT_CONFIG" | jq -r '.Layers[].Arn' | grep -v "$LAYER_ARN" | tr '\n' ' ')
    
    # Update function configuration without our layer
    aws lambda update-function-configuration \
        --function-name "$FUNCTION" \
        --layers $CURRENT_LAYERS \
        --region "$REGION"
    
    if [ $? -eq 0 ]; then
        echo "Successfully detached layer from $FUNCTION"
    else
        echo "Error detaching layer from $FUNCTION"
        exit 1
    fi
done

echo "Layer detachment complete!" 