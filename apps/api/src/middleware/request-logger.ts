import type { RequestHandler } from 'express';
import { performance } from 'node:perf_hooks';

import { logger } from '../lib/logger.js';

export const requestLogger: RequestHandler = (request, response, next) => {
  const startedAt = performance.now();

  response.on('finish', () => {
    logger.info('HTTP request completed', {
      method: request.method,
      path: request.path,
      statusCode: response.statusCode,
      durationMs: Math.round(performance.now() - startedAt),
    });
  });

  next();
};
