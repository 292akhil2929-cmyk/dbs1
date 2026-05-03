#!/usr/bin/env node
/**
 * End-to-end API smoke test.
 *
 * Assumes:
 * - DB is initialized (npm run init:db OR schema.sql imported)
 * - backend server is running (npm start)
 */

require('dotenv').config();

const BASE_URL = process.env.BASE_URL || `http://localhost:${process.env.PORT || 3000}`;

async function http(method, path, { token, body } = {}) {
  const res = await fetch(`${BASE_URL}${path}`, {
    method,
    headers: {
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...(body ? { 'Content-Type': 'application/json' } : {}),
    },
    body: body ? JSON.stringify(body) : undefined,
  });

  const text = await res.text();
  let json;
  try { json = text ? JSON.parse(text) : null; } catch { json = text; }

  if (!res.ok) {
    const msg = typeof json === 'object' && json && json.error ? json.error : text;
    throw new Error(`${method} ${path} -> ${res.status} ${res.statusText}: ${msg}`);
  }
  return json;
}

function randEmail() {
  const n = Math.random().toString(16).slice(2);
  return `smoke_${Date.now()}_${n}@example.com`;
}

async function main() {
  console.log(`▶ Smoke test against ${BASE_URL}`);

  // 0) Health
  const health = await http('GET', '/api/health');
  if (!health?.ok) throw new Error('Health check failed');
  console.log('✅ /api/health');

  // 1) Browse products
  const list = await http('GET', '/api/products?limit=5');
  const product = list?.products?.[0];
  if (!product) throw new Error('No products returned. Did seed data load?');
  console.log(`✅ /api/products (picked product_id=${product.product_id})`);

  // 2) Register + login (customer)
  const email = randEmail();
  const password = 'password123';
  const full_name = 'Smoke Tester';

  const reg = await http('POST', '/api/auth/register', { body: { email, password, full_name } });
  const token = reg?.token;
  if (!token) throw new Error('Register did not return token');
  console.log('✅ /api/auth/register');

  const login = await http('POST', '/api/auth/login', { body: { email, password } });
  const userToken = login?.token;
  if (!userToken) throw new Error('Login did not return token');
  console.log('✅ /api/auth/login');

  // 3) Add address
  const addr = await http('POST', '/api/users/addresses', {
    token: userToken,
    body: {
      label: 'Home',
      full_name,
      street: '123 Test Street',
      city: 'Dubai',
      country: 'UAE',
      postal_code: '00000',
      is_default: 1,
    },
  });
  const address_id = addr?.address_id;
  if (!address_id) throw new Error('Address was not created');
  console.log(`✅ /api/users/addresses (address_id=${address_id})`);

  // 4) Cart add + read
  await http('POST', '/api/cart', { token: userToken, body: { product_id: product.product_id, quantity: 1 } });
  const cart = await http('GET', '/api/cart', { token: userToken });
  if (!Array.isArray(cart?.items) || cart.items.length < 1) throw new Error('Cart did not contain items');
  console.log('✅ /api/cart add + get');

  // 5) Checkout (stored procedure sp_place_order)
  const checkout = await http('POST', '/api/orders/checkout', {
    token: userToken,
    body: { address_id, payment_method: 'cash_on_delivery', shipping_method: 'Standard' },
  });
  const order_id = checkout?.order_id;
  if (!order_id) throw new Error('Checkout did not return order_id');
  console.log(`✅ /api/orders/checkout (order_id=${order_id})`);

  // 6) Order detail
  const order = await http('GET', `/api/orders/${order_id}`, { token: userToken });
  if (!Array.isArray(order?.items) || order.items.length < 1) throw new Error('Order detail missing items');
  console.log('✅ /api/orders/:id');

  // 7) Admin analytics (uses views / procedures)
  const adminLogin = await http('POST', '/api/auth/login', {
    body: { email: 'admin@shopsphere.com', password: 'adminpass123' },
  });
  const adminToken = adminLogin?.token;
  if (!adminToken) throw new Error('Admin login failed (check seed data credentials in schema.sql)');
  console.log('✅ admin login');

  await http('GET', '/api/users/admin/dashboard', { token: adminToken });
  await http('GET', '/api/users/admin/top-products?limit=5', { token: adminToken });
  await http('GET', '/api/users/admin/revenue-by-category', { token: adminToken });
  await http('GET', '/api/users/admin/low-stock', { token: adminToken });
  await http('GET', '/api/users/admin/customer-ltv', { token: adminToken });
  await http('GET', '/api/users/admin/above-avg-price', { token: adminToken });
  await http('GET', '/api/users/admin/vip-customers', { token: adminToken });
  await http('GET', '/api/users/admin/audit-log', { token: adminToken });
  console.log('✅ admin analytics endpoints');

  console.log('\n✅ SMOKE TEST PASSED');
}

main().catch((e) => {
  console.error('\n❌ SMOKE TEST FAILED');
  console.error(e.message || e);
  process.exit(1);
});

