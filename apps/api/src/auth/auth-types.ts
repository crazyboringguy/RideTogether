export type PublicUser = {
  id: string;
  name: string;
  email: string;
  createdAt: string;
};

export type UserWithPassword = PublicUser & {
  passwordHash: string;
};

export type AuthResult = {
  user: PublicUser;
  token: string;
};

export type AuthenticatedUser = PublicUser & {
  sessionId: string;
};
