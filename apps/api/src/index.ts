import { app } from './app.js';
import { environment } from './config/environment.js';
import { logger } from './lib/logger.js';

const server = app.listen(environment.port, () => {
  logger.info('API server started', {
    port: environment.port,
    environment: environment.nodeEnv,
  });
});

const shutDown = (signal: string): void => {
  logger.info('API server shutting down', { signal });
  server.close(() => process.exit(0));
};

process.once('SIGINT', () => shutDown('SIGINT'));
process.once('SIGTERM', () => shutDown('SIGTERM'));
