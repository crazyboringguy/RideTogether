import { randomBytes } from 'node:crypto';

import { AppError } from '../lib/app-error.js';
import { PgTripRepository } from './pg-trip-repository.js';
import type { TripRepository } from './trip-repository.js';
import type { Trip, TripMember, UserTrip } from './trip-types.js';

type CreateTripRequest = { name: string; source: string; destination: string };

const joinCodeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

function joinCode(): string {
  return Array.from(
    randomBytes(8),
    (byte) => joinCodeAlphabet[byte % joinCodeAlphabet.length],
  ).join('');
}

function uniqueViolation(error: unknown): boolean {
  return typeof error === 'object' && error !== null && 'code' in error && error.code === '23505';
}

export class TripService {
  constructor(private readonly repository: TripRepository) {}

  async create(hostUserId: string, input: CreateTripRequest): Promise<Trip> {
    for (let attempt = 0; attempt < 5; attempt += 1) {
      try {
        return await this.repository.createTripWithHost({
          ...input,
          hostUserId,
          joinCode: joinCode(),
        });
      } catch (error) {
        if (!uniqueViolation(error)) throw error;
      }
    }
    throw new AppError(503, 'Unable to create a trip. Please try again.');
  }

  async join(userId: string, code: string): Promise<Trip> {
    const trip = await this.repository.findTripByJoinCode(code);
    if (!trip) throw new AppError(404, 'Invalid join code.');
    if (!(await this.repository.addMember(trip.id, userId))) {
      throw new AppError(409, 'You are already a member of this trip.');
    }
    return trip;
  }

  async getForMember(tripId: string, userId: string): Promise<Trip> {
    const trip = await this.repository.findTripForMember(tripId, userId);
    if (!trip) throw new AppError(404, 'Trip not found.');
    return trip;
  }

  listForUser(userId: string): Promise<UserTrip[]> {
    return this.repository.listTripsForUser(userId);
  }

  async listMembers(tripId: string, userId: string): Promise<TripMember[]> {
    await this.getForMember(tripId, userId);
    return this.repository.listMembers(tripId);
  }
}

export function createProductionTripService(): TripService {
  return new TripService(new PgTripRepository());
}
