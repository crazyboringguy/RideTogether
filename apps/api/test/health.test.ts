import request from 'supertest';
import { describe, expect, it } from 'vitest';

import { app } from '../src/app.js';

describe('GET /health', () => {
  it('reports that the API is available', async () => {
    const response = await request(app).get('/health');

    expect(response.status).toBe(200);
    expect(response.body).toMatchObject({
      service: 'ridetogether-api',
      status: 'ok',
    });
    expect(Number.isNaN(Date.parse(response.body.timestamp))).toBe(false);
  });
});
