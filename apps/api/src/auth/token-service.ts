import { SignJWT, jwtVerify } from 'jose';

import { environment } from '../config/environment.js';
import { AppError } from '../lib/app-error.js';

export type TokenPayload = { userId: string; sessionId: string };

export class TokenService {
  readonly #configuredSecret?: Uint8Array;

  constructor(secret = environment.authJwtSecret) {
    this.#configuredSecret =
      secret && secret.length >= 32 ? new TextEncoder().encode(secret) : undefined;
  }

  async issue(payload: TokenPayload): Promise<string> {
    return new SignJWT({ sid: payload.sessionId })
      .setProtectedHeader({ alg: 'HS256' })
      .setSubject(payload.userId)
      .setIssuedAt()
      .setExpirationTime(`${environment.authTokenTtlMinutes}m`)
      .sign(this.secret());
  }

  async verify(token: string): Promise<TokenPayload> {
    try {
      const { payload } = await jwtVerify(token, this.secret(), { algorithms: ['HS256'] });
      if (!payload.sub || typeof payload.sid !== 'string')
        throw new Error('Invalid token payload.');
      return { userId: payload.sub, sessionId: payload.sid };
    } catch (error) {
      if (error instanceof AppError) {
        throw error;
      }
      throw new AppError(401, 'Invalid or expired authentication token.');
    }
  }

  private secret(): Uint8Array {
    if (!this.#configuredSecret) throw new AppError(503, 'Authentication is not configured.');
    return this.#configuredSecret;
  }
}
