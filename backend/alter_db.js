const { pool } = require('./db');
async function run() {
  try {
    await pool.query('ALTER TABLE customers MODIFY phone varchar(15) NULL;');
    console.log('Table structure altered successfully.');
  } catch(e) {
    console.error(e);
  } finally {
    process.exit();
  }
}
run();
