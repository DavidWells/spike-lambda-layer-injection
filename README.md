# Lambda Layer Environment Variable Injection

Lambda Layers provide a way to package and distribute additional code and configuration that can be shared across multiple Lambda functions. This project shows how to leverage this feature to inject environment variables into existing Lambda functions.

Essentially a "hot swap" on hardcoded values or code.

## Notes

The layer approach I described would primarily make sense in specific scenarios:

- When your configuration is too complex for environment variables (like large JSON structures)
- When you want configuration changes to be part of your CI/CD deployment process
- When you need to include binary files or other resources that can't be stored in environment variables

Aside, you can just update ENV variables directly with config.

```bash
aws lambda update-function-configuration --function-name function1 --environment "Variables={KEY=value}"
```

The above is actually easier than what we are demonstrating here lol. But imagine your static data is giant (a layer can be up to 50 MB unzipped). 

## Prerequisites

- AWS CLI configured with appropriate credentials
- Node.js and npm installed
- Serverless Framework installed globally (`npm install -g serverless`)

## Project Structure

```
.
├── config-layer
├── scripts/
│   ├── layer-package.sh
│   ├── layer-publish.sh
│   ├── layer-attach.sh
│   └── layer-detach.sh
├── package.json
└── serverless.yml
```

## Available Scripts

- `npm run package-layer`: Packages the Lambda layer
- `npm run publish-layer`: Publishes the layer to AWS
- `npm run delete-layer`: Deletes the layer from AWS
- `npm run attach`: Attaches the layer to a Lambda function
- `npm run detach`: Detaches the layer from a Lambda function
- `npm run deploy`: Deploys the serverless stack
- `npm run remove`: Removes the serverless stack and deletes the layer

## How It Works

1. The layer contains configuration that overrides environment variables
2. When attached to a Lambda function, the layer's configuration takes precedence
3. This allows for dynamic environment variable updates without function redeployment

## Usage

1. Deploy your Lambda function:
   ```bash
   npm run deploy
   ```

2. Package and publish the layer:
   ```bash
   npm run package-layer
   npm run publish-layer
   ```

3. Attach the layer to your Lambda function:
   ```bash
   npm run attach
   ```

4. To remove the layer:
   ```bash
   npm run detach
   ```

## Benefits

- No need to redeploy Lambda functions to update code / values
- Reusable across multiple Lambda functions

## License

MIT 