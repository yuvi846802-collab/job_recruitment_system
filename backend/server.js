const app = require('./src/app');
require('dotenv').config();

const PORT = process.env.PORT || 5000;
const HOST = process.env.HOST || '0.0.0.0';

app.listen(PORT, HOST, () => {
  console.log(`
====================================================================
🚀 JRMS BACKEND REST API SERVER IS RUNNING
====================================================================
📡 Listening on: http://${HOST}:${PORT}
🏥 Health Check: http://localhost:${PORT}/api/health
📁 Uploads URL: http://localhost:${PORT}/uploads/
====================================================================
  `);
});

