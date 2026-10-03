import type { Trip, TripMember, UserTrip } from './trip-types.js';

export type CreateTripInput = {
  hostUserId: string;
  name: string;
  source: string;
  destination: string;
  joinCode: string;
};

export interface TripRepository {
  createTripWithHost(input: CreateTripInput): Promise<Trip>;
  findTripForMember(tripId: string, userId: string): Promise<Trip | null>;
  findTripByJoinCode(joinCode: string): Promise<Trip | null>;
  addMember(tripId: string, userId: string): Promise<boolean>;
  listTripsForUser(userId: string): Promise<UserTrip[]>;
  listMembers(tripId: string): Promise<TripMember[]>;
}
