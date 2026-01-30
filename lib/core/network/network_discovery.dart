import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../features/discovery/domain/entities/peer_device.dart';
import '../constants/network_constants.dart';
import 'network_manager.dart';

class NetworkDiscovery extends GetxController {
  final NetworkManager _networkManager = Get.find();

  final RxList<PeerDevice> _discoveredPeers = <PeerDevice>[].obs;
  List<PeerDevice> get discoveredPeers => _discoveredPeers;

  Timer? _scanTimer;
  WebSocketChannel? _broadcastChannel;

  @override
  void onInit() {
    super.onInit();
    _startDiscovery();
  }

  @override
  void onClose() {
    stopDiscovery();
    super.onClose();
  }

  void _startDiscovery() {
    // For web, we'll use WebSocket signaling server approach
    // Instead of UDP broadcast, connect to a signaling server
    _connectToSignalingServer();

    _scanTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _broadcastPresence();
    });
  }

  Future<void> _connectToSignalingServer() async {
    const signalingServerUrl = 'ws://localhost:8888';

    try {
      print('🔌 Attempting to connect to signaling server...');

      _broadcastChannel = WebSocketChannel.connect(Uri.parse(signalingServerUrl));

      print('✅ Connected to signaling server');

      _broadcastChannel!.stream.listen(
        (message) {
          print('📨 Received message: $message');
          _handleDiscoveryMessage(message);
        },
        onError: (error) {
          print('❌ Stream error: $error');
        },
        onDone: () {
          print('⚠️ Connection closed');
        },
      );

      _broadcastPresence();
    } catch (e) {
      print('❌ Failed to connect to signaling server: $e');
    }
  }

  void _broadcastPresence() {
    if (_broadcastChannel == null) return;

    final presenceData = {
      'type': NetworkConstants.msgTypePresence,
      'ip': _networkManager.localIp,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _broadcastChannel!.sink.add(jsonEncode(presenceData));
  }

  void _handleDiscoveryMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;

      if (data['type'] == NetworkConstants.msgTypePresence ||
          data['type'] == NetworkConstants.msgTypePresenceResponse) {
        final peerIp = data['ip'] as String?;

        if (peerIp != null && peerIp != _networkManager.localIp) {
          _addOrUpdatePeer(peerIp, data);
        }
      }
    } catch (e) {
      debugPrint('Error handling discovery message: $e');
    }
  }

  void _addOrUpdatePeer(String ip, Map<String, dynamic> data) {
    final existingIndex = _discoveredPeers.indexWhere((p) => p.ipAddress == ip);

    final peer = PeerDevice(
      id: data['userId'] ?? ip,
      ipAddress: ip,
      deviceName: data['deviceName'] ?? 'Unknown Device',
      userName: data['userName'] ?? 'Unknown User',
      isOnline: true,
      lastSeen: DateTime.now(),
    );

    if (existingIndex >= 0) {
      _discoveredPeers[existingIndex] = peer;
    } else {
      _discoveredPeers.add(peer);
    }

    _cleanupOfflinePeers();
  }

  void _cleanupOfflinePeers() {
    final now = DateTime.now();
    _discoveredPeers.removeWhere((peer) {
      return now.difference(peer.lastSeen).inSeconds > 15;
    });
  }

  void stopDiscovery() {
    _scanTimer?.cancel();
    _broadcastChannel?.sink.close();
    _discoveredPeers.clear();
  }

  void restartDiscovery() {
    stopDiscovery();
    _startDiscovery();
  }
}
