import request from 'supertest';
import { beforeEach, describe, expect, it } from 'vitest';

import { AuthService } from '../src/auth/auth-service.js';
import type { AuthRepository, CreateUserInput } from '../src/auth/auth-repository.js';
import type { PublicUser, UserWithPassword } from '../src/auth/auth-types.js';
import { TokenService } from '../src/auth/token-service.js';
import { createApp } from '../src/app.js';
import type { CreateTripInput, TripRepository } from '../src/trips/trip-repository.js';
import { TripService } from '../src/trips/trip-service.js';
import type { Trip, TripMember, TripRole, UserTrip } from '../src/trips/trip-types.js';

class InMemoryAuthRepository implements AuthRepository {
  private readonly users = new Map<string, UserWithPassword>();
  private readonly sessions = new Map<
    string,
    { userId: string; expiresAt: Date; revoked: boolean }
  >();
  private nextUserId = 1;
  private nextSessionId = 1;

  async createUser(input: CreateUserInput): Promise<PublicUser> {
    if ([...this.users.values()].some((user) => user.email === input.email)) {
      throw Object.assign(new Error('duplicate'), { code: '23505' });
    }
    const user: UserWithPassword = {
      id: `user-${this.nextUserId++}`,
      name: input.name,
      email: input.email,
      passwordHash: input.passwordHash,
      createdAt: new Date().toISOString(),
    };
    this.users.set(user.id, user);
    return this.publicUser(user);
  }

  async findUserByEmail(email: string): Promise<UserWithPassword | null> {
    return [...this.users.values()].find((user) => user.email === email) ?? null;
  }

  async findUserById(id: string): Promise<PublicUser | null> {
    const user = this.users.get(id);
    return user ? this.publicUser(user) : null;
  }

  async createSession(userId: string, expiresAt: Date): Promise<string> {
    const id = `session-${this.nextSessionId++}`;
    this.sessions.set(id, { userId, expiresAt, revoked: false });
    return id;
  }

  async isSessionActive(sessionId: string, userId: string): Promise<boolean> {
    const session = this.sessions.get(sessionId);
    return Boolean(
      session && session.userId === userId && !session.revoked && session.expiresAt > new Date(),
    );
  }

  async revokeSession(sessionId: string, userId: string): Promise<void> {
    const session = this.sessions.get(sessionId);
    if (session?.userId === userId) session.revoked = true;
  }

  private publicUser(user: UserWithPassword): PublicUser {
    return { id: user.id, name: user.name, email: user.email, createdAt: user.createdAt };
  }
}

class InMemoryTripRepository implements TripRepository {
  private readonly trips = new Map<string, Trip>();
  private readonly members = new Map<string, Map<string, TripRole>>();
  private nextId = 1;

  async createTripWithHost(input: CreateTripInput): Promise<Trip> {
    if ([...this.trips.values()].some((trip) => trip.joinCode === input.joinCode)) {
      throw Object.assign(new Error('duplicate'), { code: '23505' });
    }
    const now = new Date().toISOString();
    const trip: Trip = {
      id: `00000000-0000-4000-8000-${String(this.nextId++).padStart(12, '0')}`,
      ...input,
      createdAt: now,
      updatedAt: now,
    };
    this.trips.set(trip.id, trip);
    this.members.set(trip.id, new Map([[input.hostUserId, 'host']]));
    return trip;
  }

  async findTripForMember(tripId: string, userId: string): Promise<Trip | null> {
    return this.members.get(tripId)?.has(userId) ? (this.trips.get(tripId) ?? null) : null;
  }

  async findTripByJoinCode(joinCode: string): Promise<Trip | null> {
    return [...this.trips.values()].find((trip) => trip.joinCode === joinCode) ?? null;
  }

  async addMember(tripId: string, userId: string): Promise<boolean> {
    const members = this.members.get(tripId)!;
    if (members.has(userId)) return false;
    members.set(userId, 'member');
    return true;
  }

  async listTripsForUser(userId: string): Promise<UserTrip[]> {
    return [...this.trips.values()]
      .filter((trip) => this.members.get(trip.id)?.has(userId))
      .map((trip) => ({ ...trip, role: this.members.get(trip.id)!.get(userId)! }));
  }

  async listMembers(tripId: string): Promise<TripMember[]> {
    return [...this.members.get(tripId)!.entries()].map(([id, role]) => ({
      id,
      name: `User ${id}`,
      email: `${id}@example.test`,
      role,
      joinedAt: new Date().toISOString(),
    }));
  }
}

describe('trip endpoints', () => {
  let app: ReturnType<typeof createApp>;

  beforeEach(() => {
    app = createApp(
      new AuthService(new InMemoryAuthRepository(), new TokenService('a'.repeat(32))),
      new TripService(new InMemoryTripRepository()),
    );
  });

  async function register(name: string, email: string): Promise<string> {
    const response = await request(app)
      .post('/auth/register')
      .send({ name, email, password: 'safe-password-123' });
    return response.body.token as string;
  }

  async function createTrip(token: string) {
    return request(app)
      .post('/trips')
      .set('Authorization', `Bearer ${token}`)
      .send({ name: 'Coastal ride', source: 'Mumbai', destination: 'Goa' });
  }

  it('creates a trip and automatically adds its creator as host', async () => {
    const token = await register('Host Rider', 'host@example.test');
    const created = await createTrip(token);

    expect(created.status).toBe(201);
    expect(created.body.trip).toMatchObject({
      name: 'Coastal ride',
      source: 'Mumbai',
      destination: 'Goa',
    });
    expect(created.body.trip.joinCode).toMatch(/^[A-HJ-NP-Z2-9]{8}$/);
    const members = await request(app)
      .get(`/trips/${created.body.trip.id}/members`)
      .set('Authorization', `Bearer ${token}`);
    expect(members.status).toBe(200);
    expect(members.body.members).toHaveLength(1);
    expect(members.body.members[0].role).toBe('host');
  });

  it('requires authentication and validates trip input', async () => {
    await request(app)
      .post('/trips')
      .send({ name: 'Ride', source: 'A', destination: 'B' })
      .expect(401);
    const token = await register('Host Rider', 'host@example.test');
    await request(app)
      .post('/trips')
      .set('Authorization', `Bearer ${token}`)
      .send({ name: '', source: 'Mumbai', destination: 'Goa' })
      .expect(400);
  });

  it('rejects unauthenticated trip access and malformed trip IDs', async () => {
    const hostToken = await register('Host Rider', 'host@example.test');
    const created = await createTrip(hostToken);
    const tripId = created.body.trip.id as string;

    await request(app).post('/trips/join').send({ joinCode: created.body.trip.joinCode }).expect(401);
    await request(app).get(`/trips/${tripId}`).expect(401);
    await request(app).get(`/trips/${tripId}/members`).expect(401);
    await request(app)
      .get('/trips/not-a-uuid')
      .set('Authorization', `Bearer ${hostToken}`)
      .expect(400);
    await request(app)
      .get('/trips/not-a-uuid/members')
      .set('Authorization', `Bearer ${hostToken}`)
      .expect(400);
  });

  it('joins a trip, rejects bad codes and duplicate membership', async () => {
    const hostToken = await register('Host Rider', 'host@example.test');
    const memberToken = await register('Member Rider', 'member@example.test');
    const created = await createTrip(hostToken);
    const joinCode = created.body.trip.joinCode as string;

    await request(app)
      .post('/trips/join')
      .set('Authorization', `Bearer ${memberToken}`)
      .send({ joinCode })
      .expect(200);
    await request(app)
      .post('/trips/join')
      .set('Authorization', `Bearer ${memberToken}`)
      .send({ joinCode })
      .expect(409);
    await request(app)
      .post('/trips/join')
      .set('Authorization', `Bearer ${memberToken}`)
      .send({ joinCode: 'ABCDEFGH' })
      .expect(404);
  });

  it('limits trip details and members to members and lists a user trips with roles', async () => {
    const hostToken = await register('Host Rider', 'host@example.test');
    const memberToken = await register('Member Rider', 'member@example.test');
    const outsiderToken = await register('Outside Rider', 'outside@example.test');
    const created = await createTrip(hostToken);
    const tripId = created.body.trip.id as string;
    await request(app)
      .post('/trips/join')
      .set('Authorization', `Bearer ${memberToken}`)
      .send({ joinCode: created.body.trip.joinCode })
      .expect(200);

    await request(app)
      .get(`/trips/${tripId}`)
      .set('Authorization', `Bearer ${memberToken}`)
      .expect(200);
    await request(app)
      .get(`/trips/${tripId}`)
      .set('Authorization', `Bearer ${outsiderToken}`)
      .expect(404);
    await request(app)
      .get(`/trips/${tripId}/members`)
      .set('Authorization', `Bearer ${outsiderToken}`)
      .expect(404);
    const trips = await request(app).get('/trips').set('Authorization', `Bearer ${memberToken}`);
    expect(trips.status).toBe(200);
    expect(trips.body.trips).toMatchObject([{ id: tripId, role: 'member' }]);
    const outsiderTrips = await request(app)
      .get('/trips')
      .set('Authorization', `Bearer ${outsiderToken}`);
    expect(outsiderTrips.status).toBe(200);
    expect(outsiderTrips.body.trips).toEqual([]);
  });
});
