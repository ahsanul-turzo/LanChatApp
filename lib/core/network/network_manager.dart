import 'dart:async';

import 'package:get/get.dart';

class NetworkManager extends GetxController {
  final Rx<String?> _localIp = Rx<String?>('192.168.20.12'); // Hardcode for web
  final Rx<String?> _subnet = Rx<String?>('192.168.20.0');
  final RxBool _isConnected = true.obs; // Always true for web

  String? get localIp => _localIp.value;
  String? get subnet => _subnet.value;
  bool get isConnected => _isConnected.value;

  @override
  void onInit() {
    super.onInit();
    print('🌐 NetworkManager initialized with IP: ${_localIp.value}');
  }

  // For web, user can set their IP manually
  void setLocalIp(String ip) {
    _localIp.value = ip;
    final parts = ip.split('.');
    _subnet.value = '${parts[0]}.${parts[1]}.${parts[2]}.0';
    print('🌐 IP set to: $ip, Subnet: ${_subnet.value}');
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
    // No-op for web
  }
}
