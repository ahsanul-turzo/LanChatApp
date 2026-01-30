import 'package:get_storage/get_storage.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/peer_device_model.dart';

abstract class DiscoveryLocalDataSource {
  Future<List<PeerDeviceModel>> getCachedPeers();
  Future<void> cachePeers(List<PeerDeviceModel> peers);
  Future<void> clearCache();
}

class DiscoveryLocalDataSourceImpl implements DiscoveryLocalDataSource {
  final GetStorage storage;

  DiscoveryLocalDataSourceImpl(this.storage);

  @override
  Future<List<PeerDeviceModel>> getCachedPeers() async {
    try {
      final data = storage.read(AppConstants.storageKeyPeers);
      if (data == null) return [];

      final List<dynamic> jsonList = data as List<dynamic>;
      return jsonList.map((json) => PeerDeviceModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw CacheException('Failed to get cached peers: $e');
    }
  }

  @override
  Future<void> cachePeers(List<PeerDeviceModel> peers) async {
    try {
      final jsonList = peers.map((peer) => peer.toJson()).toList();
      await storage.write(AppConstants.storageKeyPeers, jsonList);
    } catch (e) {
      throw CacheException('Failed to cache peers: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await storage.remove(AppConstants.storageKeyPeers);
    } catch (e) {
      throw CacheException('Failed to clear cache: $e');
    }
  }
}
