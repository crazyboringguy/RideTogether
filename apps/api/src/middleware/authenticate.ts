import type { RequestHandler } from 'express';

import type { AuthService } from '../auth/auth-service.js';
import { AppError } from '../lib/app-error.js';

function bearerToken(header: string | undefined): string {
  const match = header?.match(/^Bearer (.+)$/i);
  if (!match) throw new AppError(401, 'Authentication is required.');
  return match[1];
}

export function authenticate(authService: AuthService): RequestHandler {
  return async (request, response, next) => {
    try {
      response.locals.authenticatedUser = await authService.authenticate(
        bearerToken(request.header('authorization')),
      );
      next();
    } catch (error) {
      next(error);
    }
  };
}
