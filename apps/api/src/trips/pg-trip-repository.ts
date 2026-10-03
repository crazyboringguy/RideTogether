import type { PoolClient, QueryResultRow } from 'pg';

import { databasePool } from '../db/pool.js';
import type { CreateTripInput, TripRepository } from './trip-repository.js';
import type { Trip, TripMember, TripRole, UserTrip } from './trip-types.js';

type TripRow = QueryResultRow & {
  id: string;
  host_user_id: string;
  name: string;
  source: string;
  destination: string;
  join_code: string;
  created_at: Date;
  updated_at: Date;
  role?: TripRole;
};

type MemberRow = QueryResultRow & {
  id: string;
  display_name: string;
  email: string;
  role: TripRole;
  joined_at: Date;
};

function toTrip(row: TripRow): Trip {
  return {
    id: row.id,
    hostUserId: row.host_user_id,
    name: row.name,
    source: row.source,
    destination: row.destination,
    joinCode: row.join_code,
    createdAt: row.created_at.toISOString(),
    updatedAt: row.updated_at.toISOString(),
  };
}

export class PgTripRepository implements TripRepository {
  async createTripWithHost(input: CreateTripInput): Promise<Trip> {
    const client = await databasePool().connect();
    try {
      await client.query('BEGIN');
      const trip = await this.insertTrip(client, input);
      await client.query(
        `INSERT INTO ridetogether.trip_members (trip_id, user_id, role)
         VALUES ($1, $2, 'host')`,
        [trip.id, input.hostUserId],
      );
      await client.query('COMMIT');
      return trip;
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  async findTripForMember(tripId: string, userId: string): Promise<Trip | null> {
    const result = await databasePool().query<TripRow>(
      `SELECT t.id, t.host_user_id, t.name, t.source, t.destination, t.join_code, t.created_at, t.updated_at
       FROM ridetogether.trips t
       INNER JOIN ridetogether.trip_members tm ON tm.trip_id = t.id
       WHERE t.id = $1 AND tm.user_id = $2`,
      [tripId, userId],
    );
    return result.rows[0] ? toTrip(result.rows[0]) : null;
  }

  async findTripByJoinCode(joinCode: string): Promise<Trip | null> {
    const result = await databasePool().query<TripRow>(
      `SELECT id, host_user_id, name, source, destination, join_code, created_at, updated_at
       FROM ridetogether.trips WHERE join_code = $1`,
      [joinCode],
    );
    return result.rows[0] ? toTrip(result.rows[0]) : null;
  }

  async addMember(tripId: string, userId: string): Promise<boolean> {
    const result = await databasePool().query(
      `INSERT INTO ridetogether.trip_members (trip_id, user_id, role)
       VALUES ($1, $2, 'member')
       ON CONFLICT (trip_id, user_id) DO NOTHING
       RETURNING trip_id`,
      [tripId, userId],
    );
    return result.rowCount === 1;
  }

  async listTripsForUser(userId: string): Promise<UserTrip[]> {
    const result = await databasePool().query<TripRow>(
      `SELECT t.id, t.host_user_id, t.name, t.source, t.destination, t.join_code, t.created_at, t.updated_at, tm.role
       FROM ridetogether.trips t
       INNER JOIN ridetogether.trip_members tm ON tm.trip_id = t.id
       WHERE tm.user_id = $1
       ORDER BY t.created_at DESC`,
      [userId],
    );
    return result.rows.map((row) => ({ ...toTrip(row), role: row.role! }));
  }

  async listMembers(tripId: string): Promise<TripMember[]> {
    const result = await databasePool().query<MemberRow>(
      `SELECT u.id, u.display_name, u.email, tm.role, tm.joined_at
       FROM ridetogether.trip_members tm
       INNER JOIN ridetogether.users u ON u.id = tm.user_id
       WHERE tm.trip_id = $1
       ORDER BY tm.joined_at ASC`,
      [tripId],
    );
    return result.rows.map((row) => ({
      id: row.id,
      name: row.display_name,
      email: row.email,
      role: row.role,
      joinedAt: row.joined_at.toISOString(),
    }));
  }

  private async insertTrip(client: PoolClient, input: CreateTripInput): Promise<Trip> {
    const result = await client.query<TripRow>(
      `INSERT INTO ridetogether.trips (host_user_id, name, source, destination, join_code)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING id, host_user_id, name, source, destination, join_code, created_at, updated_at`,
      [input.hostUserId, input.name, input.source, input.destination, input.joinCode],
    );
    return toTrip(result.rows[0]);
  }
}
