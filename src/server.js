const express = require('express');
const prometheus = require('prom-client');
const path = require('path');

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

// Estadísticas en memoria para el dashboard
const stats = {
  totalRequests: 0,
  requestsByEndpoint: {},
  responseTimes: [],
  startTime: Date.now()
};

// Middleware para métricas y stats
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const route = req.route ? req.route.path : req.path;
    
    // Actualizar Prometheus
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

    // Actualizar stats internos
    stats.totalRequests++;
    const endpointKey = `${req.method} ${route}`;
    stats.requestsByEndpoint[endpointKey] = (stats.requestsByEndpoint[endpointKey] || 0) + 1;
    stats.responseTimes.push(duration * 1000);
    
    // Mantener solo últimos 100 tiempos de respuesta
    if (stats.responseTimes.length > 100) {
      stats.responseTimes.shift();
    }
  });
  
  next();
});

// Middleware para parsear JSON
app.use(express.json());

// Servir archivos estáticos
app.use(express.static(path.join(__dirname, '../public')));

// Rutas
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, '../public/index.html'));
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

  // Calcular requests por minuto
  const uptimeMinutes = uptime / 60;
  const requestsPerMin = uptimeMinutes > 0 ? stats.totalRequests / uptimeMinutes : 0;

  // Preparar stats de endpoints para el gráfico
  const endpointStats = Object.entries(stats.requestsByEndpoint)
    .map(([endpoint, count]) => ({
      name: endpoint.replace('GET ', '').replace('POST ', ''),
      count: count
    }))
    .sort((a, b) => b.count - a.count)
    .slice(0, 6); // Top 6 endpoints

  res.json({
    totalRequests: stats.totalRequests,
    requestsPerMin: requestsPerMin,
    avgResponseTime: avgResponseTime,
    uptime: uptime,
    endpointStats: endpointStats,
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

// Endpoint para simular carga
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

// Manejo de errores
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Error interno del servidor',
    message: process.env.NODE_ENV === 'development' ? err.message : undefined,
    timestamp: new Date().toISOString()
  });
});

// Manejo de rutas no encontradas
app.use((req, res) => {
  res.status(404).json({
    error: 'Ruta no encontrada',
    path: req.path,
    timestamp: new Date().toISOString()
  });
});

// Iniciar servidor
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`
╔════════════════════════════════════════════════════════╗
║                                                        ║
║   🚀 Servidor CI/CD Monitoring Dashboard              ║
║                                                        ║
║   📍 URL:        http://localhost:${PORT}                  ║
║   🏥 Health:     http://localhost:${PORT}/health           ║
║   📊 Metrics:    http://localhost:${PORT}/metrics          ║
║   🔌 API:        http://localhost:${PORT}/api/data         ║
║                                                        ║
║   ✨ Dashboard visual disponible en la raíz           ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
  `);
});

// Manejo de señales de terminación
const gracefulShutdown = () => {
  console.log('\n🛑 Recibida señal de terminación, cerrando servidor...');
  server.close(() => {
    console.log('✅ Servidor cerrado correctamente');
    process.exit(0);
  });
  
  // Forzar cierre después de 10 segundos
  setTimeout(() => {
    console.error('⚠️  Forzando cierre del servidor');
    process.exit(1);
  }, 10000);
};

process.on('SIGTERM', gracefulShutdown);
process.on('SIGINT', gracefulShutdown);

module.exports = app;