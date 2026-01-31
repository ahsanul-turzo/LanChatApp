import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lan_chat_app/features/profile/presentation/controllers/profile_controller.dart';
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
    const signalingServerUrl = 'ws://192.168.20.12:8888';

    try {
      debugPrint('🔌 Attempting to connect to signaling server...');

      _broadcastChannel = WebSocketChannel.connect(Uri.parse(signalingServerUrl));

      debugPrint('✅ Connected to signaling server');

      _broadcastChannel!.stream.listen(
        (message) {
          String messageString;
          if (message is List<int>) {
            messageString = String.fromCharCodes(message);
          } else {
            messageString = message as String;
          }

          debugPrint('📨 Received message: $messageString');

          try {
            final data = jsonDecode(messageString) as Map<String, dynamic>;
            final type = data['type'] as String?;

            // Handle IP info from server
            if (type == 'IP_INFO') {
              String? ip = data['ip'] as String?;

              // Fix IPv6 localhost and convert to LAN IP
              if (ip == '::1' || ip == '127.0.0.1' || ip == 'unknown') {
                debugPrint('⚠️ Server returned localhost ($ip), using fallback LAN IP');
                ip = '192.168.20.12'; // Your actual LAN IP
              }

              if (ip != null) {
                _networkManager.setIpFromServer(ip);
                debugPrint('✅ IP set, now broadcasting presence');
                _broadcastPresence();
              }
              return;
            }

            if (type == 'PRESENCE' || type == 'PRESENCE_RESPONSE') {
              _handleDiscoveryMessage(messageString);
            }
          } catch (e) {
            debugPrint('⚠️ Error processing message: $e');
          }
        },
        onError: (error) {
          debugPrint('❌ Stream error: $error');
        },
        onDone: () {
          debugPrint('⚠️ Connection closed');
        },
      );

      _broadcastPresence();
    } catch (e) {
      debugPrint('❌ Failed to connect to signaling server: $e');
    }
  }

  void _broadcastPresence() {
    if (_broadcastChannel == null) return;

    String userId = 'unknown';
    String userName = 'Unknown User';
    String deviceName = 'Unknown Device';

    try {
      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        userId = profileController.profile?.id ?? 'unknown';
        userName = profileController.profile?.userName ?? 'Unknown User';
        deviceName = profileController.profile?.deviceName ?? 'Unknown Device';
      }
    } catch (e) {
      debugPrint('⚠️ Profile not ready: $e');
    }

    final presenceData = {
      'type': NetworkConstants.msgTypePresence,
      'ip': _networkManager.localIp,
      'userId': userId,
      'userName': userName,
      'deviceName': deviceName,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _broadcastChannel!.sink.add(jsonEncode(presenceData));
    debugPrint('📡 Broadcasting: $presenceData');
  }

  void _handleDiscoveryMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      debugPrint('🔍 Processing message type: ${data['type']}');

      if (data['type'] == NetworkConstants.msgTypePresence ||
          data['type'] == NetworkConstants.msgTypePresenceResponse) {
        final peerIp = data['ip'] as String?;
        final userId = data['userId'] as String?;
        final userName = data['userName'] as String?;
        final deviceName = data['deviceName'] as String?;

        debugPrint('👤 Peer data - IP: $peerIp, User: $userName, Device: $deviceName');

        if (peerIp != null && userId != null && userId != 'unknown') {
          // Try to get ProfileController safely
          String? currentUserId;
          try {
            if (Get.isRegistered<ProfileController>()) {
              final profileController = Get.find<ProfileController>();
              currentUserId = profileController.profile?.id;
            }
          } catch (e) {
            debugPrint('⚠️ ProfileController not ready yet');
          }

          // Don't add self
          if (userId == currentUserId) {
            debugPrint('⏭️ Skipping self');
            return;
          }

          final peer = PeerDevice(
            id: userId,
            ipAddress: peerIp,
            deviceName: deviceName ?? 'Unknown Device',
            userName: userName ?? 'Unknown User',
            isOnline: true,
            lastSeen: DateTime.now(),
          );

          // Check if peer exists
          final existingIndex = _discoveredPeers.indexWhere((p) => p.id == userId);

          if (existingIndex >= 0) {
            debugPrint('🔄 Updating existing peer: $userName');
            _discoveredPeers[existingIndex] = peer;
          } else {
            debugPrint('✅ Adding new peer: $userName');
            _discoveredPeers.add(peer);
          }

          debugPrint('📊 Total peers: ${_discoveredPeers.length}');
        }
      }
    } catch (e) {
      debugPrint('❌ Error handling discovery message: $e');
    }
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
