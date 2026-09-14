const mysql = require('mysql2/promise');
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

let dbType = 'none'; // 'pg' | 'mysql' | 'mock'
let pgPool = null;
let mysqlPool = null;
let isConnected = false;

// Determine Supabase / PostgreSQL configuration
const pgUrl = process.env.DIRECT_URL || process.env.DATABASE_URL;
const isPgConfigured = pgUrl && !pgUrl.includes('[YOUR-PASSWORD]');

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '3306'),
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'recruitment_db',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  multipleStatements: true
};

async function initDB() {
  // 1. Try PostgreSQL (Supabase) if URL is configured
  if (isPgConfigured) {
    try {
      console.log('⚡ Initializing PostgreSQL (Supabase) connection...');
      pgPool = new Pool({
        connectionString: pgUrl,
        ssl: { rejectUnauthorized: false },
        connectionTimeoutMillis: 10000,
        idleTimeoutMillis: 30000
      });

      // Prevent unhandled error crashes on idle pool client drops
      pgPool.on('error', (err) => {
        console.warn('⚠️ Idle PostgreSQL client warning:', err.message);
      });

      // Test connection
      await pgPool.query('SELECT 1');
      dbType = 'pg';
      isConnected = true;
      console.log('✅ Connected to Supabase PostgreSQL Database successfully!');

      // Check if users table exists
      try {
        const tableCheck = await pgPool.query(
          "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'users';"
        );

        if (tableCheck.rows.length === 0) {
          console.log('⚡ Empty Supabase DB detected. Executing pg_schema.sql & pg_seed.sql...');
          const pgSchemaPath = path.join(__dirname, '../../database/pg_schema.sql');
          const pgSeedPath = path.join(__dirname, '../../database/pg_seed.sql');

          if (fs.existsSync(pgSchemaPath)) {
            const schemaSql = fs.readFileSync(pgSchemaPath, 'utf8');
            await pgPool.query(schemaSql);
          }
          if (fs.existsSync(pgSeedPath)) {
            const seedSql = fs.readFileSync(pgSeedPath, 'utf8');
            await pgPool.query(seedSql);
          }
          console.log('✅ Supabase PostgreSQL Schema & Seed data initialized!');
        }
      } catch (seedErr) {
        console.warn(`⚠️ Supabase Table Check / Seed Notice: ${seedErr.message}`);
      }
      return;
    } catch (pgErr) {
      console.warn(`⚠️ Supabase PostgreSQL Connection Error: ${pgErr.message}`);
      console.warn('ℹ️ Falling back to MySQL or resilient mode...');
    }
  }

  // 2. Try MySQL connection
  try {
    const rootConn = await mysql.createConnection({
      host: dbConfig.host,
      port: dbConfig.port,
      user: dbConfig.user,
      password: dbConfig.password,
      multipleStatements: true
    });

    await rootConn.query(`CREATE DATABASE IF NOT EXISTS \`${dbConfig.database}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`);
    await rootConn.end();

    mysqlPool = mysql.createPool(dbConfig);
    mysqlPool.on('error', (err) => {
      console.warn('⚠️ MySQL Pool warning:', err.message);
    });
    
    const [tables] = await mysqlPool.query(`SHOW TABLES FROM \`${dbConfig.database}\`;`);
    if (tables.length === 0) {
      console.log('⚡ Empty MySQL database detected. Executing schema.sql & seed.sql...');
      const schemaSql = fs.readFileSync(path.join(__dirname, '../../database/schema.sql'), 'utf8');
      await mysqlPool.query(schemaSql);
      
      const seedSql = fs.readFileSync(path.join(__dirname, '../../database/seed.sql'), 'utf8');
      await mysqlPool.query(seedSql);
      console.log('✅ MySQL database schema and seed data loaded successfully!');
    } else {
      console.log(`✅ Connected to MySQL database: ${dbConfig.database} (${tables.length} tables verified)`);
    }

    dbType = 'mysql';
    isConnected = true;
  } catch (mysqlErr) {
    console.warn(`⚠️ MySQL Database Notice: ${mysqlErr.message}`);
    console.warn(`ℹ️ Operating in resilient backend mode.`);
    try {
      mysqlPool = mysql.createPool(dbConfig);
      dbType = 'mysql';
    } catch (e) {
      console.warn('Failed to create fallback pool:', e.message);
    }
  }
}

// Convert MySQL SQL placeholders (?) to PostgreSQL ($1, $2, ...)
function convertToPgSql(sql) {
  let paramIdx = 1;
  let pgSql = sql.replace(/\?/g, () => `$${paramIdx++}`);
  
  // If query is an INSERT and does not have RETURNING, append RETURNING id
  if (/^\s*INSERT\s+INTO/i.test(pgSql) && !/RETURNING/i.test(pgSql)) {
    pgSql += ' RETURNING id';
  }
  return pgSql;
}

// Unified query abstraction layer
async function query(sql, params = []) {
  try {
    if (dbType === 'pg' && pgPool) {
      const formattedSql = convertToPgSql(sql);
      const result = await pgPool.query(formattedSql, params);
      
      const rows = result.rows || [];
      rows.affectedRows = result.rowCount || 0;
      rows.insertId = (rows[0] && rows[0].id) ? rows[0].id : null;
      return rows;
    } else if (mysqlPool) {
      const [rows] = await mysqlPool.execute(sql, params);
      return rows;
    } else {
      console.warn('Database query executed without active DB connection pool.');
      return [];
    }
  } catch (err) {
    console.error('Database Query Error:', err.message);
    throw err;
  }
}

// Safe async initialization
initDB().catch(err => {
  console.warn('⚠️ DB Initialization background warning:', err.message);
});

module.exports = {
  getPool: () => (dbType === 'pg' ? pgPool : mysqlPool),
  query,
  isConnected: () => isConnected,
  getDbType: () => dbType,
  initDB
};
