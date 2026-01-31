import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:network_info_plus/network_info_plus.dart';

class NetworkManager extends GetxController {
  final NetworkInfo _networkInfo = NetworkInfo();

  final Rx<String?> _localIp = Rx<String?>(null);
  final Rx<String?> _subnet = Rx<String?>(null);
  final RxBool _isConnected = false.obs;

  String? get localIp => _localIp.value;
  String? get subnet => _subnet.value;
  bool get isConnected => _isConnected.value;

  Timer? _checkTimer;

  @override
  void onInit() {
    super.onInit();
    if (!kIsWeb) _startNetworkCheck();
  }

  @override
  void onClose() {
    _checkTimer?.cancel();
    super.onClose();
  }

  // Called by NetworkDiscovery when server sends IP
  void setIpFromServer(String ip) {
    _localIp.value = ip;
    _subnet.value = _calculateSubnet(ip);
    _isConnected.value = true;
    debugPrint('🌐 IP received from server: $ip');
  }

  void _startNetworkCheck() {
    _checkNetworkInfo();
    _checkTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkNetworkInfo();
    });
  }

  Future<void> _checkNetworkInfo() async {
    try {
      final wifiIP = await _networkInfo.getWifiIP();

      if (wifiIP != null && wifiIP.isNotEmpty) {
        _localIp.value = wifiIP;
        _subnet.value = _calculateSubnet(wifiIP);
        _isConnected.value = true;
        debugPrint('🌐 IP detected: $wifiIP');
      } else {
        _localIp.value = null;
        _subnet.value = null;
        _isConnected.value = false;
        debugPrint('⚠️ No IP detected');
      }
    } catch (e) {
      debugPrint('⚠️ Network detection failed: $e');
      _localIp.value = null;
      _isConnected.value = false;
    }
  }

  String _calculateSubnet(String ip) {
    final parts = ip.split('.');
    return '${parts[0]}.${parts[1]}.${parts[2]}.0';
  }

  List<String> getSubnetIpRange() {
    if (_subnet.value == null) return [];

    final subnetParts = _subnet.value!.split('.');
    final List<String> ipRange = [];

    for (int i = 1; i < 255; i++) {
      final ip = '${subnetParts[0]}.${subnetParts[1]}.${subnetParts[2]}.$i';
      if (ip != _localIp.value) {
        ipRange.add(ip);
      }
    }

    return ipRange;
  }

  Future<void> refreshNetworkInfo() async {
    await _checkNetworkInfo();
  }
}
