import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lan_chat_app/core/network/socket_service.dart';
import 'package:lan_chat_app/features/profile/presentation/controllers/profile_controller.dart';

import '../../features/discovery/domain/entities/peer_device.dart';
import '../constants/network_constants.dart';
import 'network_manager.dart';

class NetworkDiscovery extends GetxController {
  // Recommended style final NetworkManager _networkManager = Get.find(); instead of Get.find<NetworkManager>();
  final NetworkManager _networkManager = Get.find();

  final RxList<PeerDevice> _discoveredPeers = <PeerDevice>[].obs;

  List<PeerDevice> get discoveredPeers => _discoveredPeers;

  Timer? _scanTimer;

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
    // SocketService is already connected in DI
    final socketService = Get.find<SocketService>();

    if (!socketService.isConnected) {
      debugPrint('⚠️ SocketService not connected yet, waiting...');
      await Future.delayed(const Duration(seconds: 1));
    }

    debugPrint('✅ Using shared WebSocket connection');

    // Listen to messages from shared connection
    socketService.messageStream.listen((data) {
      final type = data['type'] as String?;

      if (type == 'IP_INFO') {
        String? ip = data['ip'] as String?;
        if (ip == '::1' || ip == '127.0.0.1' || ip == 'unknown') {
          ip = '192.168.20.12';
        }
        if (ip != null) {
          _networkManager.setIpFromServer(ip);
          _broadcastPresence();
        }
      } else if (type == 'PRESENCE' || type == 'PRESENCE_RESPONSE') {
        _handleDiscoveryMessage(jsonEncode(data));
      }
    });

    _broadcastPresence();
  }

  void _broadcastPresence() {
    final socketService = Get.find<SocketService>();

    if (!socketService.isConnected) {
      debugPrint('⚠️ Cannot broadcast: not connected');
      return;
    }

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

    socketService.sendMessage(presenceData); // Instead of _broadcastChannel
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
    _discoveredPeers.clear();
  }

  void restartDiscovery() {
    stopDiscovery();
    _startDiscovery();
  }
}
