import { Router } from 'express';

export const healthRouter = Router();

healthRouter.get('/health', (_request, response) => {
  response.status(200).json({
    service: 'ridetogether-api',
    status: 'ok',
    timestamp: new Date().toISOString(),
  });
});
