const WebSocket = require('ws');
const http = require('http');

const server = http.createServer((req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.end('WebSocket Server Running');
});

const wss = new WebSocket.Server({ server });
const clients = new Map(); // ws -> { userId, ip, userName, deviceName }
const userSockets = new Map(); // userId -> ws (for quick lookup)
const messageQueue = new Map(); // userId -> [messages] (for offline delivery)

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
      const userId = data.userId;

      // Store client info
      clients.set(ws, {
        ip: data.ip,
        userId: userId,
        userName: data.userName,
        deviceName: data.deviceName,
        timestamp: data.timestamp
      });

      // Map userId to socket for quick lookup
      userSockets.set(userId, ws);

      // Broadcast presence to all other clients
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

      // Send existing clients' presence to new client
      clients.forEach((clientData, clientWs) => {
        if (clientWs !== ws && clientWs.readyState === WebSocket.OPEN) {
          ws.send(JSON.stringify({
            type: 'PRESENCE_RESPONSE',
            ...clientData
          }));
        }
      });

      // Deliver any queued messages for this user
      if (messageQueue.has(userId)) {
        const pendingMessages = messageQueue.get(userId);
        console.log(`📬 Delivering ${pendingMessages.length} queued messages to ${data.userName}`);

        pendingMessages.forEach((msg) => {
          ws.send(JSON.stringify(msg));
        });

        // Clear the queue
        messageQueue.delete(userId);
      }

    } else if (data.type === 'TEXT' || data.type === 'IMAGE' || data.type === 'FILE') {
      const receiverId = data.receiverId;
      const receiverWs = userSockets.get(receiverId);

      console.log(`💬 Chat message from ${data.senderId} to ${receiverId}`);

      if (receiverWs && receiverWs.readyState === WebSocket.OPEN) {
        // Receiver is online - deliver directly
        console.log(`📤 Delivering message directly to ${receiverId}`);
        receiverWs.send(message);
      } else {
        // Receiver is offline - queue the message
        console.log(`📥 Queuing message for offline user ${receiverId}`);

        if (!messageQueue.has(receiverId)) {
          messageQueue.set(receiverId, []);
        }
        messageQueue.get(receiverId).push(data);

        // Also notify sender that message is queued (optional)
        ws.send(JSON.stringify({
          type: 'MESSAGE_QUEUED',
          messageId: data.id,
          receiverId: receiverId
        }));
      }
    } else {
      // Broadcast other message types
      wss.clients.forEach((client) => {
        if (client !== ws && client.readyState === WebSocket.OPEN) {
          client.send(message);
        }
      });
    }
  });

  ws.on('close', () => {
    const clientData = clients.get(ws);
    if (clientData) {
      console.log(`✗ Client disconnected: ${clientData.userName} (${clientData.userId})`);
      userSockets.delete(clientData.userId);
      // Note: We keep queued messages even after disconnect
    } else {
      console.log('✗ Client disconnected');
    }
    clients.delete(ws);
  });

  ws.on('error', (error) => {
    console.error('❌ WebSocket error:', error.message);
  });
});

server.listen(8888, '0.0.0.0', () => {
  console.log('📡 Server listening on all interfaces at port 8888');
});
