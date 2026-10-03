import { Router } from 'express';

import type { AuthService } from '../auth/auth-service.js';
import type { AuthenticatedUser } from '../auth/auth-types.js';
import { authenticate } from '../middleware/authenticate.js';
import type { TripService } from '../trips/trip-service.js';
import {
  parseCreateTripRequest,
  parseJoinTripRequest,
  parseTripId,
} from '../trips/trip-validation.js';

export function createTripRouter(authService: AuthService, tripService: TripService): Router {
  const router = Router();
  router.use(authenticate(authService));

  router.post('/', async (request, response, next) => {
    try {
      const user = response.locals.authenticatedUser as AuthenticatedUser;
      response
        .status(201)
        .json({ trip: await tripService.create(user.id, parseCreateTripRequest(request.body)) });
    } catch (error) {
      next(error);
    }
  });

  router.post('/join', async (request, response, next) => {
    try {
      const user = response.locals.authenticatedUser as AuthenticatedUser;
      const { joinCode } = parseJoinTripRequest(request.body);
      response.status(200).json({ trip: await tripService.join(user.id, joinCode) });
    } catch (error) {
      next(error);
    }
  });

  router.get('/', async (_request, response, next) => {
    try {
      const user = response.locals.authenticatedUser as AuthenticatedUser;
      response.status(200).json({ trips: await tripService.listForUser(user.id) });
    } catch (error) {
      next(error);
    }
  });

  router.get('/:id', async (request, response, next) => {
    try {
      const user = response.locals.authenticatedUser as AuthenticatedUser;
      response
        .status(200)
        .json({ trip: await tripService.getForMember(parseTripId(request.params.id), user.id) });
    } catch (error) {
      next(error);
    }
  });

  router.get('/:id/members', async (request, response, next) => {
    try {
      const user = response.locals.authenticatedUser as AuthenticatedUser;
      response
        .status(200)
        .json({
          members: await tripService.listMembers(parseTripId(request.params.id), user.id),
        });
    } catch (error) {
      next(error);
    }
  });

  return router;
}
