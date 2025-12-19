const request = require('supertest');
const app = require('./app');

describe('Rutas adicionales de la API', () => {
  describe('GET /api/stats', () => {
    it('debe devolver estadísticas de la aplicación', async () => {
      const response = await request(app).get('/api/stats');
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('totalRequests');
      expect(response.body).toHaveProperty('requestsPerMin');
      expect(response.body).toHaveProperty('avgResponseTime');
      expect(response.body).toHaveProperty('endpointStats');
      expect(Array.isArray(response.body.endpointStats)).toBe(true);
    });
  });

  describe('GET /api/simulate-load', () => {
    it('debe simular carga y devolver delay', async () => {
      const response = await request(app).get('/api/simulate-load');
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('message', 'Carga simulada');
      expect(response.body).toHaveProperty('delay');
      expect(response.body).toHaveProperty('timestamp');
    });
  });

  describe('Error handler', () => {
    it('debe devolver 500 en caso de error interno', async () => {
      // Definimos una ruta temporal que lanza un error
      app.get('/error', () => {
        throw new Error('Test error');
      });

      const response = await request(app).get('/error');
      expect(response.status).toBe(500);
      expect(response.body).toHaveProperty('error', 'Error interno del servidor');
      expect(response.body).toHaveProperty('timestamp');
    });
  });
});
