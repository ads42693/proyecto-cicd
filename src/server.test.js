const request = require('supertest');
const { app, server } = require('./server');

afterAll(() => {
  // Cerrar el servidor al terminar los tests
  server.close();
});

describe('API Endpoints', () => {
  describe('GET /', () => {
    it('debe responder con mensaje de bienvenida', async () => {
      const response = await request(app).get('/');
      
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('message');
      expect(response.body).toHaveProperty('version');
      expect(response.body).toHaveProperty('timestamp');
    });
  });

  describe('GET /health', () => {
    it('debe responder con estado healthy', async () => {
      const response = await request(app).get('/health');
      
      expect(response.status).toBe(200);
      expect(response.body.status).toBe('healthy');
      expect(response.body).toHaveProperty('uptime');
      expect(response.body).toHaveProperty('timestamp');
    });
  });

  describe('GET /api/data', () => {
    it('debe retornar un array de datos', async () => {
      const response = await request(app).get('/api/data');
      
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('data');
      expect(Array.isArray(response.body.data)).toBe(true);
      expect(response.body.data.length).toBeGreaterThan(0);
    });
  });

  describe('POST /api/echo', () => {
    it('debe hacer echo del body recibido', async () => {
      const testData = { test: 'data' };
      const response = await request(app)
        .post('/api/echo')
        .send(testData)
        .set('Content-Type', 'application/json');
      
      expect(response.status).toBe(200);
      expect(response.body.received).toEqual(testData);
      expect(response.body).toHaveProperty('timestamp');
    });
  });

  describe('GET /metrics', () => {
    it('debe exponer métricas de Prometheus', async () => {
      const response = await request(app).get('/metrics');
      
      expect(response.status).toBe(200);
      expect(response.text).toContain('http_requests_total');
    });
  });

  describe('GET /nonexistent', () => {
    it('debe retornar 404 para rutas no existentes', async () => {
      const response = await request(app).get('/nonexistent');
      
      expect(response.status).toBe(404);
      expect(response.body).toHaveProperty('error');
    });
  });
});
