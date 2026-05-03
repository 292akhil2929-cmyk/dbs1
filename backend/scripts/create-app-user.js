#!/usr/bin/env node
/**
 * Creates a dedicated MySQL user for the ShopSphere app and grants privileges.
 *
 * Run with ROOT credentials:
 *   set ROOT_DB_PASSWORD=...
 *   node scripts/create-app-user.js
 */

require('dotenv').config();
const mysql = require('mysql2/promise');

const {
  ROOT_DB_HOST,
  ROOT_DB_PORT,
  ROOT_DB_USER,
  ROOT_DB_PASSWORD,
  DB_HOST = 'localhost',
  DB_PORT = '3306',
  DB_NAME = 'shopsphere',
  APP_DB_USER = 'shopsphere_user',
  APP_DB_PASSWORD = 'ShopSphereApp@123',
} = process.env;

async function main() {
  const host = ROOT_DB_HOST || DB_HOST;
  const port = parseInt(ROOT_DB_PORT || DB_PORT, 10) || 3306;
  const user = ROOT_DB_USER || 'root';
  const password = ROOT_DB_PASSWORD;

  if (!password) {
    console.error('ROOT_DB_PASSWORD is required (root/admin password).');
    process.exit(1);
  }

  const conn = await mysql.createConnection({ host, port, user, password, multipleStatements: true });

  const appUser = APP_DB_USER;
  const appPass = APP_DB_PASSWORD;

  // Create user and grant.
  await conn.query(`CREATE USER IF NOT EXISTS \`${appUser}\`@'%' IDENTIFIED BY ?`, [appPass]);
  await conn.query(`GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON \`${DB_NAME}\`.* TO \`${appUser}\`@'%'`);
  await conn.query(`FLUSH PRIVILEGES`);

  console.log(`✅ App DB user ensured: ${appUser}`);
  console.log(`✅ Granted privileges on ${DB_NAME}.* (SELECT/INSERT/UPDATE/DELETE/EXECUTE)`);

  await conn.end();
}

main().catch((e) => {
  console.error(e.message || e);
  process.exit(1);
});

