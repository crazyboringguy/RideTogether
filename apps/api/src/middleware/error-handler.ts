import type { ErrorRequestHandler, RequestHandler } from 'express';

import { logger } from '../lib/logger.js';

export const notFoundHandler: RequestHandler = (request, response) => {
  response.status(404).json({
    error: 'Not found',
    path: request.path,
  });
};

export const errorHandler: ErrorRequestHandler = (error, _request, response, _next) => {
  logger.error('Unhandled request error', {
    error: error instanceof Error ? error.message : 'Unknown error',
  });

  response.status(500).json({ error: 'Internal server error' });
};
