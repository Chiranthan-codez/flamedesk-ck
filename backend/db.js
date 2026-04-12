const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host: process.env.DB_HOST || process.env.MYSQLHOST || 'localhost',
  port: Number(process.env.DB_PORT || process.env.MYSQLPORT || 3307),
  user: process.env.DB_USER || process.env.MYSQLUSER || 'root',
  password: process.env.DB_PASS || process.env.MYSQLPASSWORD || 'xzvb##1234A',
  database: process.env.DB_NAME || process.env.MYSQLDATABASE || 'cloud_kitchen',
  waitForConnections: true,
  connectionLimit: Number(process.env.DB_CONNECTION_LIMIT || 10),
});

async function testDatabaseConnection() {
  const connection = await pool.getConnection();
  try {
    await connection.query('SELECT 1');
  } finally {
    connection.release();
  }
}

module.exports = {
  pool,
  testDatabaseConnection,
};
