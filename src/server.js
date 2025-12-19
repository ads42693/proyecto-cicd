const app = require('./app');
const PORT = process.env.PORT || 3000;

const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Servidor escuchando en http://localhost:${PORT}`);
});

const gracefulShutdown = () => {
  console.log('\n🛑 Recibida señal de terminación, cerrando servidor...');
  server.close(() => {
    console.log('✅ Servidor cerrado correctamente');
    process.exit(0);
  });
  setTimeout(() => {
    console.error('⚠️  Forzando cierre del servidor');
    process.exit(1);
  }, 10000);
};

process.on('SIGTERM', gracefulShutdown);
process.on('SIGINT', gracefulShutdown);

module.exports = server;
