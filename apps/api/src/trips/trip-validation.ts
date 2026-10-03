import { z } from 'zod';

import { AppError } from '../lib/app-error.js';

const text = (field: string, maximum: number) =>
  z.string().trim().min(2, `${field} must contain at least 2 characters.`).max(maximum);

const createTripSchema = z
  .object({
    name: text('Trip name', 120),
    source: text('Source', 160),
    destination: text('Destination', 160),
  })
  .strict();

const joinTripSchema = z
  .object({
    joinCode: z
      .string()
      .trim()
      .toUpperCase()
      .regex(/^[A-HJ-NP-Z2-9]{8}$/, 'Invalid join code.'),
  })
  .strict();

const tripIdSchema = z.string().uuid('Invalid trip ID.');

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

export const parseCreateTripRequest = (body: unknown) => parse(createTripSchema, body);
export const parseJoinTripRequest = (body: unknown) => parse(joinTripSchema, body);
export const parseTripId = (value: unknown) => parse(tripIdSchema, value);
