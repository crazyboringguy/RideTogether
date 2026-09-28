import type { PublicUser, UserWithPassword } from './auth-types.js';

export type CreateUserInput = {
  name: string;
  email: string;
  passwordHash: string;
};

export interface AuthRepository {
  createUser(input: CreateUserInput): Promise<PublicUser>;
  findUserByEmail(email: string): Promise<UserWithPassword | null>;
  findUserById(id: string): Promise<PublicUser | null>;
  createSession(userId: string, expiresAt: Date): Promise<string>;
  isSessionActive(sessionId: string, userId: string): Promise<boolean>;
  revokeSession(sessionId: string, userId: string): Promise<void>;
}
