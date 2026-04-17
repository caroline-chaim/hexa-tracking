const express = require('express');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 8080;

// __dirname já é a pasta build/web, então serve direto
app.use(express.static(__dirname));

app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html')); // ← sem build/web
});

app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});