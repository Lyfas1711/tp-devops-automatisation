const request = require('supertest');
const app = require('../src/app');

describe('API Tests', () => {

  // Test route GET /
  test('GET / - doit retourner le message de bienvenue', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('message');
    expect(res.body.message).toContain('Bienvenue');
  });

  // Test route GET /ping
  test('GET /ping - doit retourner pong', async () => {
    const res = await request(app).get('/ping');
    expect(res.statusCode).toBe(200);
    expect(res.body.response).toBe('pong');
    expect(res.body).toHaveProperty('timestamp');
  });

  // Test route GET /status
  test('GET /status - doit retourner le statut ok', async () => {
    const res = await request(app).get('/status');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('ok');
    expect(res.body).toHaveProperty('uptime');
  });

  // Test route inexistante
  test('GET /inexistant - doit retourner 404', async () => {
    const res = await request(app).get('/inexistant');
    expect(res.statusCode).toBe(404);
  });

});
