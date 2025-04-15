const fs = require('fs');

function getConfig(key, defaultValue = null) {
  // Try to load config from layer (if present)
  try {
  
    const configPath = '/opt/config/settings.json';
    
    if (fs.existsSync(configPath)) {
      const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
      if (config && config[key] !== undefined) {
        return config[key];
      }
    }
  } catch (err) {
    // Layer not present or has issues
    console.log(`Config layer not detected or error: ${err.message}`);
  }
  
  // Fall back to environment variables
  if (process.env[key] !== undefined) {
    return process.env[key];
  }
  
  // Use the default value as final fallback
  return defaultValue;
}

module.exports = { getConfig };
