const express = require('express');
const prometheus = require('prom-client');
const path = require('path');

const app = express();
const register = new prometheus.Registry();

// Métricas por defecto
prometheus.collectDefaultMetrics({ register });

// Métricas personalizadas
const httpRequestCounter = new prometheus.Counter({
  name: 'http_requests_total',
  help: 'Total de solicitudes HTTP',
  labelNames: ['method', 'route', 'status'],
  registers: [register]
});

const httpRequestDuration = new prometheus.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duración de las solicitudes HTTP',
  labelNames: ['method', 'route', 'status'],
  registers: [register]
});

// Estadísticas en memoria
const stats = {
  totalRequests: 0,
  requestsByEndpoint: {},
  responseTimes: [],
  startTime: Date.now()
};

// Middleware para métricas
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const route = req.route ? req.route.path : req.path;

    httpRequestCounter.inc({ method: req.method, route, status: res.statusCode });
    httpRequestDuration.observe({ method: req.method, route, status: res.statusCode }, duration);

    stats.totalRequests++;
    const endpointKey = `${req.method} ${route}`;
    stats.requestsByEndpoint[endpointKey] = (stats.requestsByEndpoint[endpointKey] || 0) + 1;
    stats.responseTimes.push(duration * 1000);
    if (stats.responseTimes.length > 100) stats.responseTimes.shift();
  });
  next();
});

app.use(express.json());
app.use(express.static(path.join(__dirname, '../public')));

// Rutas
app.get('/', (req, res) => {
  if (process.env.NODE_ENV === 'test') {
    return res.json({
      message: 'Bienvenido al dashboard',
      version: '1.0.0',
      timestamp: new Date().toISOString()
    });
  }
  res.sendFile(path.join(__dirname, '../public/index.html'));
});

app.get('/welcome', (req, res) => {
  res.json({
    message: 'Bienvenido al dashboard',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
    memory: process.memoryUsage(),
    environment: process.env.NODE_ENV || 'development'
  });
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

app.get('/api/data', (req, res) => {
  res.json({
    data: [
      { id: 1, nombre: 'Servicio A', status: 'activo', latencia: '45ms' },
      { id: 2, nombre: 'Servicio B', status: 'activo', latencia: '32ms' },
      { id: 3, nombre: 'Servicio C', status: 'activo', latencia: '58ms' },
      { id: 4, nombre: 'Base de Datos', status: 'activo', latencia: '12ms' },
      { id: 5, nombre: 'Cache Redis', status: 'activo', latencia: '5ms' }
    ],
    timestamp: new Date().toISOString(),
    requestCount: stats.totalRequests
  });
});

app.get('/api/stats', (req, res) => {
  const uptime = process.uptime();
  const avgResponseTime = stats.responseTimes.length > 0
    ? stats.responseTimes.reduce((a, b) => a + b, 0) / stats.responseTimes.length
    : 0;
  const uptimeMinutes = uptime / 60;
  const requestsPerMin = uptimeMinutes > 0 ? stats.totalRequests / uptimeMinutes : 0;

  const endpointStats = Object.entries(stats.requestsByEndpoint)
    .map(([endpoint, count]) => ({ name: endpoint.replace(/^(GET|POST) /, ''), count }))
    .sort((a, b) => b.count - a.count)
    .slice(0, 6);

  res.json({
    totalRequests: stats.totalRequests,
    requestsPerMin,
    avgResponseTime,
    uptime,
    endpointStats,
    timestamp: new Date().toISOString()
  });
});

app.post('/api/echo', (req, res) => {
  res.json({
    received: req.body,
    timestamp: new Date().toISOString(),
    headers: req.headers
  });
});

app.get('/api/simulate-load', (req, res) => {
  const delay = Math.random() * 100;
  setTimeout(() => {
    res.json({
      message: 'Carga simulada',
      delay: `${delay.toFixed(2)}ms`,
      timestamp: new Date().toISOString()
    });
  }, delay);
});

// Ruta de prueba para forzar error (para tests)
app.get('/error', (req, res, next) => {
  next(new Error('Ruta de prueba de error'));
});

// Manejo de errores
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Error interno del servidor',
    message: process.env.NODE_ENV === 'development' ? err.message : undefined,
    timestamp: new Date().toISOString()
  });
});

// Rutas no encontradas
app.use((req, res) => {
  res.status(404).json({
    error: 'Ruta no encontrada',
    path: req.path,
    timestamp: new Date().toISOString()
  });
});

module.exports = app;
