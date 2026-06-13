const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// Route principale
app.get('/', (req, res) => {
  res.json({ message: 'Bienvenue sur l\'API DevOps TP', version: '1.0.0' });
});

// Route ping/pong
app.get('/ping', (req, res) => {
  res.json({ response: 'pong', timestamp: new Date().toISOString() });
});

// Route status
app.get('/status', (req, res) => {
  res.json({
    status: 'ok',
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// Démarrer le serveur uniquement si exécuté directement
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Serveur démarré sur le port ${PORT}`);
  });
}

module.exports = app;
