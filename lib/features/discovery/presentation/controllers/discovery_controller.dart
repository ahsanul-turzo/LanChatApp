import 'package:get/get.dart';

import '../../domain/entities/peer_device.dart';
import '../../domain/usecases/broadcast_presence.dart';
import '../../domain/usecases/scan_network.dart';

class DiscoveryController extends GetxController {
  final ScanNetwork _scanNetwork = Get.find();
  final BroadcastPresence _broadcastPresence = Get.find();

  final RxList<PeerDevice> _peers = <PeerDevice>[].obs;
  final RxBool _isScanning = false.obs;
  final RxString _error = ''.obs;

  List<PeerDevice> get peers => _peers;
  bool get isScanning => _isScanning.value;
  String get error => _error.value;

  @override
  void onInit() {
    super.onInit();
    startDiscovery();
  }

  Future<void> startDiscovery() async {
    _isScanning.value = true;
    _error.value = '';

    await _broadcastPresence();
    await scanForPeers();
  }

  Future<void> scanForPeers() async {
    final result = await _scanNetwork();

    result.fold(
      (failure) {
        _error.value = failure.message;
        _isScanning.value = false;
      },
      (peers) {
        _peers.value = peers;
        _isScanning.value = false;
      },
    );
  }

  @override
  Future<void> refresh() async {
    await startDiscovery();
  }

  void selectPeer(PeerDevice peer) {
    Get.toNamed('/chat', arguments: peer);
  }

  void clearError() {
    _error.value = '';
  }
}
