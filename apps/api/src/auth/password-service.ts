import * as argon2 from 'argon2';

export const passwordService = {
  hash: (password: string): Promise<string> =>
    argon2.hash(password, {
      type: argon2.argon2id,
      memoryCost: 19 * 1024,
      timeCost: 2,
      parallelism: 1,
    }),
  verify: (hash: string, password: string): Promise<boolean> => argon2.verify(hash, password),
};
