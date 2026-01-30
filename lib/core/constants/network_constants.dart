class NetworkConstants {
  // Ports
  static const int discoveryPort = 8888;
  static const int messagePort = 9999;
  static const int fileTransferPort = 8080;

  // Broadcast
  static const String broadcastAddress = '255.255.255.255';
  static const String multicastAddress = '239.255.255.250';

  // Message Types
  static const String msgTypePresence = 'PRESENCE';
  static const String msgTypePresenceResponse = 'PRESENCE_RESPONSE';
  static const String msgTypeText = 'TEXT';
  static const String msgTypeImage = 'IMAGE';
  static const String msgTypeFile = 'FILE';
  static const String msgTypeTyping = 'TYPING';
  static const String msgTypeDelivered = 'DELIVERED';
  static const String msgTypeRead = 'READ';
  static const String msgTypeDisconnect = 'DISCONNECT';

  // Protocol
  static const String protocolVersion = '1.0';
  static const String delimiter = '\n\n';

  // Chunk size for file transfer
  static const int fileChunkSize = 8192; // 8KB
}
