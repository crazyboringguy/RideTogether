import type { ErrorRequestHandler, RequestHandler } from 'express';

import { AppError } from '../lib/app-error.js';
import { logger } from '../lib/logger.js';

export const notFoundHandler: RequestHandler = (request, response) => {
  response.status(404).json({
    error: 'Not found',
    path: request.path,
  });
};

export const errorHandler: ErrorRequestHandler = (error, _request, response, _next) => {
  if (error instanceof SyntaxError && 'status' in error && error.status === 400) {
    response.status(400).json({ error: 'Invalid request.' });
    return;
  }

  if (error instanceof AppError) {
    response
      .status(error.statusCode)
      .json({ error: error.message, ...(error.details ? { details: error.details } : {}) });
    return;
  }

  logger.error('Unhandled request error', {
    error: error instanceof Error ? error.message : 'Unknown error',
  });

  response.status(500).json({ error: 'Internal server error' });
};
