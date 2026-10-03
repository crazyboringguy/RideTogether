import express from 'express';

import { createProductionAuthService, type AuthService } from './auth/auth-service.js';
import { errorHandler, notFoundHandler } from './middleware/error-handler.js';
import { requestLogger } from './middleware/request-logger.js';
import { createAuthRouter } from './routes/auth.js';
import { healthRouter } from './routes/health.js';
import { createTripRouter } from './routes/trips.js';
import { createProductionTripService, type TripService } from './trips/trip-service.js';

export function createApp(
  authService: AuthService = createProductionAuthService(),
  tripService: TripService = createProductionTripService(),
) {
  const app = express();

  app.disable('x-powered-by');
  app.use(express.json({ limit: '100kb' }));
  app.use(requestLogger);
  app.use(healthRouter);
  app.use('/auth', createAuthRouter(authService));
  app.use('/trips', createTripRouter(authService, tripService));
  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}

export const app = createApp();
