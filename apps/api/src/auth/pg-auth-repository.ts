import type { QueryResultRow } from 'pg';

import { databasePool } from '../db/pool.js';
import type { AuthRepository, CreateUserInput } from './auth-repository.js';
import type { PublicUser, UserWithPassword } from './auth-types.js';

type UserRow = QueryResultRow & {
  id: string;
  display_name: string;
  email: string;
  password_hash?: string;
  created_at: Date;
};

function toPublicUser(row: UserRow): PublicUser {
  return {
    id: row.id,
    name: row.display_name,
    email: row.email,
    createdAt: row.created_at.toISOString(),
  };
}

export class PgAuthRepository implements AuthRepository {
  async createUser(input: CreateUserInput): Promise<PublicUser> {
    const result = await databasePool().query<UserRow>(
      `INSERT INTO ridetogether.users (display_name, email, password_hash)
       VALUES ($1, $2, $3)
       RETURNING id, display_name, email, created_at`,
      [input.name, input.email, input.passwordHash],
    );
    return toPublicUser(result.rows[0]);
  }

  async findUserByEmail(email: string): Promise<UserWithPassword | null> {
    const result = await databasePool().query<UserRow>(
      `SELECT id, display_name, email, password_hash, created_at
       FROM ridetogether.users WHERE email = $1`,
      [email],
    );
    const row = result.rows[0];
    return row ? { ...toPublicUser(row), passwordHash: row.password_hash! } : null;
  }

  async findUserById(id: string): Promise<PublicUser | null> {
    const result = await databasePool().query<UserRow>(
      'SELECT id, display_name, email, created_at FROM ridetogether.users WHERE id = $1',
      [id],
    );
    return result.rows[0] ? toPublicUser(result.rows[0]) : null;
  }

  async createSession(userId: string, expiresAt: Date): Promise<string> {
    const result = await databasePool().query<{ id: string }>(
      `INSERT INTO ridetogether.auth_sessions (user_id, expires_at)
       VALUES ($1, $2) RETURNING id`,
      [userId, expiresAt],
    );
    return result.rows[0].id;
  }

  async isSessionActive(sessionId: string, userId: string): Promise<boolean> {
    const result = await databasePool().query(
      `SELECT 1 FROM ridetogether.auth_sessions
       WHERE id = $1 AND user_id = $2 AND revoked_at IS NULL AND expires_at > NOW()`,
      [sessionId, userId],
    );
    return result.rowCount === 1;
  }

  async revokeSession(sessionId: string, userId: string): Promise<void> {
    await databasePool().query(
      `UPDATE ridetogether.auth_sessions SET revoked_at = NOW()
       WHERE id = $1 AND user_id = $2 AND revoked_at IS NULL`,
      [sessionId, userId],
    );
  }
}
