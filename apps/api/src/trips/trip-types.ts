export type TripRole = 'host' | 'member';

export type Trip = {
  id: string;
  hostUserId: string;
  name: string;
  source: string;
  destination: string;
  joinCode: string;
  createdAt: string;
  updatedAt: string;
};

export type UserTrip = Trip & { role: TripRole };

export type TripMember = {
  id: string;
  name: string;
  email: string;
  role: TripRole;
  joinedAt: string;
};
