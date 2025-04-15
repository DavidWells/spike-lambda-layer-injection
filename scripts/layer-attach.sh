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

echo "Starting layer update process..."

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

# Function to get other layers (excluding our layer)
get_other_layers() {
    local FUNCTION_NAME=$1
    aws lambda get-function-configuration \
        --function-name "$FUNCTION_NAME" \
        --region "$REGION" \
        --query "Layers[?!contains(Arn, '${LAYER_NAME}')].Arn" \
        --output json
}

# Function to update layers
update_function_layers() {
    local FUNCTION_NAME=$1
    local LAYER_LIST=$2
    
    echo "Updating layers for function: $FUNCTION_NAME"
    aws lambda update-function-configuration \
        --function-name "$FUNCTION_NAME" \
        --layers "$LAYER_LIST" \
        --region "$REGION"
    
    if [ $? -eq 0 ]; then
        echo "Successfully updated layers for $FUNCTION_NAME"
        return 0
    else
        echo "Error updating layers for $FUNCTION_NAME"
        return 1
    fi
}

# Process each function
for FUNCTION in "${FUNCTIONS[@]}"; do
    echo "Processing function: $FUNCTION"
    
    # Get current non-config layers
    echo "Getting existing layers (excluding our layer)..."
    OTHER_LAYERS=$(get_other_layers "$FUNCTION")
    
    # Create new layer configuration
    if [ "$OTHER_LAYERS" == "null" ] || [ "$OTHER_LAYERS" == "[]" ]; then
        echo "No other layers found, attaching only our layer"
        LAYERS_JSON="[\"$LAYER_ARN\"]"
    else
        echo "Found other layers, combining with our layer"
        LAYERS_JSON="[\"$LAYER_ARN\",$(echo "$OTHER_LAYERS" | sed 's/^\[//;s/\]$//' | sed 's/,,/,/g' | sed 's/^,//;s/,$//')]"
    fi
    
    # Update the function with new layer configuration
    update_function_layers "$FUNCTION" "$LAYERS_JSON"
    if [ $? -ne 0 ]; then
        exit 1
    fi
    
    echo "Successfully processed $FUNCTION"
done

echo "Layer update process complete!" 