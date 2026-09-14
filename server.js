const path = require('path');

// Change working directory to backend folder so relative paths and .env load correctly
process.chdir(path.join(__dirname, 'backend'));

// Execute backend server
require('./server.js');
