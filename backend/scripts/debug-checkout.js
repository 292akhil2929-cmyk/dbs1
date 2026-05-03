#!/usr/bin/env node
require('dotenv').config();
const mysql = require('mysql2/promise');

async function main() {
  const conn = await mysql.createConnection({
    host: process.env.DB_HOST,
    port: parseInt(process.env.DB_PORT, 10) || 3306,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    multipleStatements: true,
  });

  // Use the latest smoke-test user's address/user if present.
  const [[addr]] = await conn.query('SELECT address_id,user_id FROM ADDRESSES ORDER BY address_id DESC LIMIT 1');
  const userId = addr?.user_id;
  const addressId = addr?.address_id;

  console.log({ userId, addressId });

  const [cart] = await conn.query('SELECT * FROM CART_ITEMS WHERE user_id=?', [userId]);
  console.log('cart', cart);

  await conn.query("SET @oid=0, @msg=''");
  try {
    await conn.query('CALL sp_place_order(?,?,?,?,?,@oid,@msg)', [
      userId,
      addressId,
      null,
      'cash_on_delivery',
      'Standard',
    ]);
  } catch (e) {
    console.log('CALL error:', e.message);
  }

  const [out] = await conn.query('SELECT @oid AS order_id, @msg AS message');
  console.log('out', out);

  const [orders] = await conn.query('SELECT order_id,status,total_amount FROM ORDERS WHERE user_id=? ORDER BY order_id DESC LIMIT 5', [userId]);
  console.log('orders', orders);

  await conn.end();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});

