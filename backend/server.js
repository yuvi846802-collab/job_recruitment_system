const app = require('./src/app');
require('dotenv').config();

const PORT = process.env.PORT || 5000;
const HOST = process.env.HOST || '0.0.0.0';

// Global Process Error Guards to prevent early termination in cloud containers
process.on('unhandledRejection', (reason, promise) => {
  console.warn('⚠️ Unhandled Rejection:', reason);
});

process.on('uncaughtException', (err) => {
  console.error('🚨 Uncaught Exception:', err.message);
});

app.listen(PORT, HOST, () => {
  console.log(`
====================================================================
🚀 JRMS BACKEND REST API SERVER IS RUNNING
====================================================================
📡 Listening on: http://${HOST}:${PORT}
🏥 Health Check: http://localhost:${PORT}/api/health
====================================================================
  `);
});
