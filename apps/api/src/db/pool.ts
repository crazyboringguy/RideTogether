import { Pool } from 'pg';

import { environment } from '../config/environment.js';
import { AppError } from '../lib/app-error.js';

let pool: Pool | undefined;

export function databasePool(): Pool {
  if (!environment.databaseUrl) throw new AppError(503, 'Database is not configured.');
  pool ??= new Pool({ connectionString: environment.databaseUrl });
  return pool;
}
