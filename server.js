const WebSocket = require('ws');
const http = require('http');

// Create HTTP server for CORS
const server = http.createServer((req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  res.end('WebSocket Server Running');
});

const wss = new WebSocket.Server({ server });

console.log('🚀 WebSocket server running on ws://localhost:8888');

wss.on('connection', (ws, req) => {
  const clientIp = req.socket.remoteAddress;
  console.log('✓ Client connected from:', clientIp);

  ws.on('message', (message) => {
    console.log('→ Message:', message.toString());

    // Broadcast to all other clients
    wss.clients.forEach((client) => {
      if (client !== ws && client.readyState === WebSocket.OPEN) {
        client.send(message);
      }
    });
  });

  ws.on('close', () => {
    console.log('✗ Client disconnected');
  });

  ws.on('error', (error) => {
    console.error('❌ WebSocket error:', error.message);
  });
});

server.listen(8888, () => {
  console.log('📡 HTTP server also listening on http://localhost:8888');
});