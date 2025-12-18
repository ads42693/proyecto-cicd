const express = require('express');
const prometheus = require('prom-client');

const app = express();
const PORT = process.env.PORT || 3000;

// Configurar métricas de Prometheus
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

// Middleware para métricas
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const route = req.route ? req.route.path : req.path;
    
    httpRequestCounter.inc({
      method: req.method,
      route: route,
      status: res.statusCode
    });
    
    httpRequestDuration.observe(
      {
        method: req.method,
        route: route,
        status: res.statusCode
      },
      duration
    );
  });
  
  next();
});

// Middleware para parsear JSON
app.use(express.json());

// Rutas
app.get('/', (req, res) => {
  res.json({
    message: '¡Bienvenido a la aplicación CI/CD!',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

app.get('/api/data', (req, res) => {
  res.json({
    data: [
      { id: 1, nombre: 'Elemento 1', activo: true },
      { id: 2, nombre: 'Elemento 2', activo: false },
      { id: 3, nombre: 'Elemento 3', activo: true }
    ]
  });
});

app.post('/api/echo', (req, res) => {
  res.json({
    received: req.body,
    timestamp: new Date().toISOString()
  });
});

// Manejo de errores
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Error interno del servidor',
    message: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// Manejo de rutas no encontradas
app.use((req, res) => {
  res.status(404).json({
    error: 'Ruta no encontrada',
    path: req.path
  });
});

// Iniciar servidor
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`Servidor ejecutándose en http://0.0.0.0:${PORT}`);
  console.log(`Métricas disponibles en http://0.0.0.0:${PORT}/metrics`);
});

// Manejo de señales de terminación
const gracefulShutdown = () => {
  console.log('Recibida señal de terminación, cerrando servidor...');
  server.close(() => {
    console.log('Servidor cerrado correctamente');
    process.exit(0);
  });
  
  setTimeout(() => {
    console.error('Forzando cierre del servidor');
    process.exit(1);
  }, 10000);
};

process.on('SIGTERM', gracefulShutdown);
process.on('SIGINT', gracefulShutdown);

// Exportar ambos: app y server
module.exports = { app, server };
