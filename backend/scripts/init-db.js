#!/usr/bin/env node
/**
 * Initializes the MySQL database by executing `db/schema.sql` using mysql2.
 *
 * Why this exists:
 * - Many evaluators don't have `mysql` CLI installed / on PATH.
 * - We want a repeatable "runs from scratch" setup using Node only.
 */

require('dotenv').config();
const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');

const {
  DB_HOST = 'localhost',
  DB_PORT = '3306',
  DB_USER = 'root',
  DB_PASSWORD = '',
} = process.env;

const schemaPath = path.join(__dirname, '..', 'db', 'schema.sql');

function splitSqlByDelimiters(sqlText) {
  // Minimal delimiter-aware SQL splitter to support:
  // - default delimiter ";"
  // - DELIMITER $$ ... $$ blocks (procedures/functions/triggers)
  //
  // We intentionally keep comments inside routine bodies intact.
  const lines = sqlText.replace(/\r\n/g, '\n').split('\n');
  let delimiter = ';';
  let buf = '';
  const stmts = [];

  const pushStmt = (raw) => {
    const s = raw.trim();
    if (!s) return;
    // drop full-line comments when not inside routine blocks
    stmts.push(s);
  };

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const m = line.match(/^\s*DELIMITER\s+(.+)\s*$/i);
    if (m) {
      // Flush anything pending before delimiter change.
      if (buf.trim()) pushStmt(buf);
      buf = '';
      delimiter = m[1];
      continue;
    }

    // Skip full-line comments and blank lines when we're at top level.
    // (We still keep inline comments and anything inside routine blocks.)
    if (!buf.trim()) {
      if (/^\s*(--|#)/.test(line)) continue;
      if (/^\s*$/.test(line)) continue;
    }

    buf += line + '\n';

    // Statement boundary: delimiter appears at end of buffer (ignoring whitespace/newlines)
    const trimmed = buf.trimEnd();
    if (trimmed.endsWith(delimiter)) {
      const stmt = trimmed.slice(0, -delimiter.length);
      pushStmt(stmt);
      buf = '';
    }
  }

  if (buf.trim()) pushStmt(buf);
  return stmts;
}

async function main() {
  if (!fs.existsSync(schemaPath)) {
    console.error(`schema.sql not found at: ${schemaPath}`);
    process.exit(1);
  }

  const sql = fs.readFileSync(schemaPath, 'utf8');
  const statements = splitSqlByDelimiters(sql);

  const conn = await mysql.createConnection({
    host: DB_HOST,
    port: parseInt(DB_PORT, 10) || 3306,
    user: DB_USER,
    password: DB_PASSWORD,
    // no database specified intentionally: schema.sql creates/uses it
    multipleStatements: false,
  });

  console.log(`✅ Connected to MySQL at ${DB_HOST}:${DB_PORT} as ${DB_USER}`);
  console.log(`▶ Executing schema.sql (${statements.length} statements) ...`);

  try {
    for (let idx = 0; idx < statements.length; idx++) {
      const s = statements[idx];
      await conn.query(s);
      if ((idx + 1) % 50 === 0) console.log(`  ... ${idx + 1}/${statements.length}`);
    }
    console.log('✅ Database initialized successfully.');
  } catch (e) {
    console.error('❌ Failed while executing schema.sql.');
    console.error(e.message);
    process.exitCode = 1;
  } finally {
    await conn.end();
  }
}

main().catch((e) => {
  console.error(e.message || e);
  process.exit(1);
});

