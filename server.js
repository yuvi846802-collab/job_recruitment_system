const path = require('path');

// Global Process Error Guards to prevent container exit
process.on('unhandledRejection', (reason, promise) => {
  console.warn('⚠️ Unhandled Rejection:', reason);
});

process.on('uncaughtException', (err) => {
  console.error('🚨 Uncaught Exception:', err.message);
});

// Change working directory to backend folder so relative paths and .env load correctly
process.chdir(path.join(__dirname, 'backend'));

// Execute backend server
require('./server.js');
