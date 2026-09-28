import { z } from 'zod';

import { AppError } from '../lib/app-error.js';

const emailSchema = z
  .string()
  .trim()
  .email()
  .max(254)
  .transform((value) => value.toLowerCase());
const passwordSchema = z
  .string()
  .min(12, 'Password must contain at least 12 characters.')
  .max(128)
  .regex(/[a-zA-Z]/, 'Password must include a letter.')
  .regex(/[0-9]/, 'Password must include a number.');

const registerSchema = z
  .object({
    name: z.string().trim().min(2, 'Name must contain at least 2 characters.').max(80),
    email: emailSchema,
    password: passwordSchema,
  })
  .strict();

const loginSchema = z.object({ email: emailSchema, password: z.string().min(1).max(128) }).strict();

function parse<T>(schema: z.ZodType<T>, body: unknown): T {
  const result = schema.safeParse(body);
  if (!result.success) {
    throw new AppError(
      400,
      'Invalid request.',
      result.error.issues.map((issue) => issue.message),
    );
  }
  return result.data;
}

export const parseRegisterRequest = (body: unknown) => parse(registerSchema, body);
export const parseLoginRequest = (body: unknown) => parse(loginSchema, body);
