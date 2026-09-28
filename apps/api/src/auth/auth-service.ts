import { environment } from '../config/environment.js';
import { AppError } from '../lib/app-error.js';
import { passwordService } from './password-service.js';
import { PgAuthRepository } from './pg-auth-repository.js';
import { TokenService } from './token-service.js';
import type { AuthRepository } from './auth-repository.js';
import type { AuthResult, AuthenticatedUser, PublicUser } from './auth-types.js';

type Credentials = { email: string; password: string };
type Registration = Credentials & { name: string };

export class AuthService {
  constructor(
    private readonly repository: AuthRepository,
    private readonly tokens: TokenService,
    private readonly sessionDurationMs = environment.authTokenTtlMinutes * 60_000,
  ) {}

  async register(input: Registration): Promise<AuthResult> {
    const passwordHash = await passwordService.hash(input.password);
    let user: PublicUser;
    try {
      user = await this.repository.createUser({ ...input, passwordHash });
    } catch (error: unknown) {
      if (
        typeof error === 'object' &&
        error !== null &&
        'code' in error &&
        error.code === '23505'
      ) {
        throw new AppError(409, 'An account with that email already exists.');
      }
      throw error;
    }
    return this.issueSession(user);
  }

  async login(input: Credentials): Promise<AuthResult> {
    const user = await this.repository.findUserByEmail(input.email);
    if (!user || !(await passwordService.verify(user.passwordHash, input.password))) {
      throw new AppError(401, 'Invalid email or password.');
    }
    return this.issueSession(user);
  }

  async authenticate(token: string): Promise<AuthenticatedUser> {
    const payload = await this.tokens.verify(token);
    if (!(await this.repository.isSessionActive(payload.sessionId, payload.userId))) {
      throw new AppError(401, 'Authentication session is no longer active.');
    }
    const user = await this.repository.findUserById(payload.userId);
    if (!user) throw new AppError(401, 'Authentication session is no longer active.');
    return { ...user, sessionId: payload.sessionId };
  }

  async logout(user: AuthenticatedUser): Promise<void> {
    await this.repository.revokeSession(user.sessionId, user.id);
  }

  private async issueSession(user: PublicUser): Promise<AuthResult> {
    const expiresAt = new Date(Date.now() + this.sessionDurationMs);
    const sessionId = await this.repository.createSession(user.id, expiresAt);
    return { user, token: await this.tokens.issue({ userId: user.id, sessionId }) };
  }
}

export function createProductionAuthService(): AuthService {
  return new AuthService(new PgAuthRepository(), new TokenService());
}
