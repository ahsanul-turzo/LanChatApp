const WebSocket = require('ws');
const http = require('http');

const server = http.createServer((req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.end('WebSocket Server Running');
});

const wss = new WebSocket.Server({ server });
const clients = new Map();

console.log('🚀 WebSocket server running on ws://localhost:8888');

wss.on('connection', (ws, req) => {
  // Extract client IP
  const clientIp = req.headers['x-forwarded-for']?.split(',')[0] ||
                   req.socket.remoteAddress?.replace('::ffff:', '') ||
                   'unknown';

  console.log('✓ Client connected from:', clientIp);

  // Send IP back to client immediately
  ws.send(JSON.stringify({
    type: 'IP_INFO',
    ip: clientIp
  }));

  ws.on('message', (message) => {
    const data = JSON.parse(message.toString());
    console.log('→ Message:', data);

    if (data.type === 'PRESENCE') {
      clients.set(ws, {
        ip: data.ip,
        userId: data.userId,
        userName: data.userName,
        deviceName: data.deviceName,
        timestamp: data.timestamp
      });

      wss.clients.forEach((client) => {
        if (client !== ws && client.readyState === WebSocket.OPEN) {
          client.send(JSON.stringify({
            type: 'PRESENCE_RESPONSE',
            ip: data.ip,
            userId: data.userId,
            userName: data.userName,
            deviceName: data.deviceName,
            timestamp: data.timestamp
          }));
        }
      });

      clients.forEach((clientData, clientWs) => {
        if (clientWs !== ws && clientWs.readyState === WebSocket.OPEN) {
          ws.send(JSON.stringify({
            type: 'PRESENCE_RESPONSE',
            ...clientData
          }));
        }
      });
    } else if (data.type === 'TEXT' || data.type === 'IMAGE' || data.type === 'FILE') {
      console.log(`💬 Chat message from ${data.senderId} to ${data.receiverId}`);

      wss.clients.forEach((client) => {
        if (client !== ws && client.readyState === WebSocket.OPEN) {
          client.send(message);
        }
      });
    } else {
      wss.clients.forEach((client) => {
        if (client !== ws && client.readyState === WebSocket.OPEN) {
          client.send(message);
        }
      });
    }
  });

  ws.on('close', () => {
    console.log('✗ Client disconnected');
    clients.delete(ws);
  });

  ws.on('error', (error) => {
    console.error('❌ WebSocket error:', error.message);
  });
});

server.listen(8888, '0.0.0.0', () => {
  console.log('📡 Server listening on all interfaces at port 8888');
});