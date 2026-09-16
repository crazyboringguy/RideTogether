import express from 'express';

import { errorHandler, notFoundHandler } from './middleware/error-handler.js';
import { requestLogger } from './middleware/request-logger.js';
import { healthRouter } from './routes/health.js';

export const app = express();

app.disable('x-powered-by');
app.use(express.json({ limit: '100kb' }));
app.use(requestLogger);
app.use(healthRouter);
app.use(notFoundHandler);
app.use(errorHandler);
