import { Router } from 'express';

import type { AuthService } from '../auth/auth-service.js';
import type { AuthenticatedUser } from '../auth/auth-types.js';
import { parseLoginRequest, parseRegisterRequest } from '../auth/validation.js';
import { authenticate } from '../middleware/authenticate.js';

export function createAuthRouter(authService: AuthService): Router {
  const router = Router();

  router.post('/register', async (request, response, next) => {
    try {
      response.status(201).json(await authService.register(parseRegisterRequest(request.body)));
    } catch (error) {
      next(error);
    }
  });

  router.post('/login', async (request, response, next) => {
    try {
      response.status(200).json(await authService.login(parseLoginRequest(request.body)));
    } catch (error) {
      next(error);
    }
  });

  router.get('/me', authenticate(authService), (request, response) => {
    const user = response.locals.authenticatedUser as AuthenticatedUser;
    response.status(200).json({ user });
  });

  router.post('/logout', authenticate(authService), async (request, response, next) => {
    try {
      await authService.logout(response.locals.authenticatedUser as AuthenticatedUser);
      response.status(204).send();
    } catch (error) {
      next(error);
    }
  });

  return router;
}
