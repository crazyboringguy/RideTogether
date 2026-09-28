import express from 'express';

import { createProductionAuthService, type AuthService } from './auth/auth-service.js';
import { errorHandler, notFoundHandler } from './middleware/error-handler.js';
import { requestLogger } from './middleware/request-logger.js';
import { createAuthRouter } from './routes/auth.js';
import { healthRouter } from './routes/health.js';

export function createApp(authService: AuthService = createProductionAuthService()) {
  const app = express();

  app.disable('x-powered-by');
  app.use(express.json({ limit: '100kb' }));
  app.use(requestLogger);
  app.use(healthRouter);
  app.use('/auth', createAuthRouter(authService));
  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}

export const app = createApp();
