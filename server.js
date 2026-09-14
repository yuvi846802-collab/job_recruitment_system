const path = require('path');

// Global Process Error Guards
process.on('unhandledRejection', (reason, promise) => {
  console.warn('⚠️ Unhandled Rejection:', reason);
});

process.on('uncaughtException', (err) => {
  console.error('🚨 Uncaught Exception:', err.message);
});

// Change working directory to backend folder
const backendDir = path.join(__dirname, 'backend');
process.chdir(backendDir);

// Execute backend server using explicit absolute path
require(path.join(backendDir, 'server.js'));
