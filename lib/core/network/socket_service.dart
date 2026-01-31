import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketService extends GetxController {
  WebSocketChannel? _channel;
  final RxBool _isConnected = false.obs;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  bool get isConnected => _isConnected.value;
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;

  String? _serverUrl;
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 5;

  @override
  void onClose() {
    disconnect();
    _messageController.close();
    super.onClose();
  }

  Future<bool> connect(String serverUrl) async {
    try {
      _serverUrl = serverUrl;

      debugPrint('🔌 Connecting to: $serverUrl');

      _channel = WebSocketChannel.connect(Uri.parse(serverUrl));

      _channel!.stream.listen(_onMessage, onError: _onError, onDone: _onDone, cancelOnError: false);

      // Wait a bit to ensure connection
      await Future.delayed(const Duration(milliseconds: 500));

      _isConnected.value = true;
      _reconnectAttempts = 0;
      _startHeartbeat();

      debugPrint('✅ Connected to WebSocket');
      return true;
    } catch (e) {
      debugPrint('❌ Connection error: $e');
      _isConnected.value = false;
      _scheduleReconnect();
      return false;
    }
  }

  void disconnect() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _isConnected.value = false;
  }

  void sendMessage(Map<String, dynamic> data) {
    if (!_isConnected.value || _channel == null) {
      debugPrint('Cannot send message: Not connected');
      return;
    }

    try {
      final jsonString = jsonEncode(data);
      _channel!.sink.add(jsonString);
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  void _onMessage(dynamic message) {
    try {
      // Convert Uint8List to String if needed
      String messageString;
      if (message is List<int>) {
        messageString = String.fromCharCodes(message);
      } else {
        messageString = message as String;
      }

      final data = jsonDecode(messageString) as Map<String, dynamic>;
      _messageController.add(data);
    } catch (e) {
      debugPrint('Error parsing message: $e');
    }
  }

  void _onError(Object error) {
    debugPrint('WebSocket error: $error');
    _isConnected.value = false;
    _scheduleReconnect();
  }

  void _onDone() {
    debugPrint('WebSocket connection closed');
    _isConnected.value = false;
    _scheduleReconnect();
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_isConnected.value) {
        sendMessage({'type': 'HEARTBEAT', 'timestamp': DateTime.now().toIso8601String()});
      }
    });
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= maxReconnectAttempts || _serverUrl == null) {
      debugPrint('Max reconnect attempts reached');
      return;
    }

    _reconnectTimer?.cancel();
    final delay = Duration(seconds: 2 * (_reconnectAttempts + 1));

    _reconnectTimer = Timer(delay, () {
      _reconnectAttempts++;
      debugPrint('Reconnecting... Attempt $_reconnectAttempts');
      connect(_serverUrl!);
    });
  }
}
