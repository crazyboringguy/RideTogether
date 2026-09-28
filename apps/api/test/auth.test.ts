import request from 'supertest';
import { beforeEach, describe, expect, it } from 'vitest';

import { AuthService } from '../src/auth/auth-service.js';
import type { AuthRepository, CreateUserInput } from '../src/auth/auth-repository.js';
import type { PublicUser, UserWithPassword } from '../src/auth/auth-types.js';
import { TokenService } from '../src/auth/token-service.js';
import { createApp } from '../src/app.js';

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
      const error = Object.assign(new Error('duplicate'), { code: '23505' });
      throw error;
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
    return {
      id: user.id,
      name: user.name,
      email: user.email,
      createdAt: user.createdAt,
    };
  }
}

describe('authentication endpoints', () => {
  let app: ReturnType<typeof createApp>;

  beforeEach(() => {
    app = createApp(
      new AuthService(new InMemoryAuthRepository(), new TokenService('a'.repeat(32))),
    );
  });

  it('registers a user and returns no password hash', async () => {
    const response = await request(app).post('/auth/register').send({
      name: 'Asha Rider',
      email: 'ASHA@EXAMPLE.COM',
      password: 'safe-password-123',
    });

    expect(response.status).toBe(201);
    expect(response.body.user).toMatchObject({ name: 'Asha Rider', email: 'asha@example.com' });
    expect(response.body).toHaveProperty('token');
    expect(JSON.stringify(response.body)).not.toContain('passwordHash');
    expect(JSON.stringify(response.body)).not.toContain('safe-password-123');
  });

  it('rejects duplicate and invalid registrations', async () => {
    const body = { name: 'Asha Rider', email: 'asha@example.com', password: 'safe-password-123' };
    await request(app).post('/auth/register').send(body).expect(201);
    await request(app).post('/auth/register').send(body).expect(409);
    const invalid = await request(app)
      .post('/auth/register')
      .send({ ...body, email: 'invalid', password: 'short' });
    expect(invalid.status).toBe(400);
  });

  it('logs in, returns the current user, and invalidates logout sessions', async () => {
    const registration = await request(app).post('/auth/register').send({
      name: 'Asha Rider',
      email: 'asha@example.com',
      password: 'safe-password-123',
    });
    const login = await request(app).post('/auth/login').send({
      email: 'ASHA@EXAMPLE.COM',
      password: 'safe-password-123',
    });

    expect(login.status).toBe(200);
    const token = login.body.token as string;
    await request(app)
      .get('/auth/me')
      .set('Authorization', `Bearer ${token}`)
      .expect(200)
      .expect(({ body }) => expect(body.user.id).toBe(registration.body.user.id));
    await request(app).post('/auth/logout').set('Authorization', `Bearer ${token}`).expect(204);
    await request(app).get('/auth/me').set('Authorization', `Bearer ${token}`).expect(401);
  });

  it('rejects invalid credentials and unauthenticated requests', async () => {
    await request(app)
      .post('/auth/login')
      .send({ email: 'nobody@example.com', password: 'safe-password-123' })
      .expect(401);
    await request(app).get('/auth/me').expect(401);
  });

  it('returns a safe validation error for malformed JSON', async () => {
    await request(app)
      .post('/auth/register')
      .set('Content-Type', 'application/json')
      .send('{')
      .expect(400, { error: 'Invalid request.' });
  });
});
