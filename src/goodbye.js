const { getConfig } = require('./utils/resolve-config');

exports.handler = async (event) => {
  console.log('Event:', JSON.stringify(event, null, 2));

  const FOO = getConfig('FOO');
  const BAZ = getConfig('BAZ');
  console.log('process.env.FOO:', process.env.FOO);
  console.log('process.env.BAZ:', process.env.BAZ);
  console.log('getConfig(FOO):', FOO);
  console.log('getConfig(BAZ):', BAZ);
  
  try {
    const queryParams = event.queryStringParameters || {};
    
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message: 'Goodbye from GET endpoint!',
        queryParams: queryParams,
        FOOFromConfig: FOO,
        BAZFromConfig: BAZ,
        FOOFromEnv: process.env.FOO,
        BAZFromEnv: process.env.BAZ
      })
    };
  } catch (error) {
    console.error('Error:', error);
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message: 'Internal server error',
        error: error.message
      })
    };
  }
}; 