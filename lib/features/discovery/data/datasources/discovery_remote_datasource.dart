import 'dart:async';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_discovery.dart';
import '../../../../core/network/network_manager.dart';
import '../models/peer_device_model.dart';

abstract class DiscoveryRemoteDataSource {
  Future<List<PeerDeviceModel>> scanNetwork();
  Future<bool> broadcastPresence();
  Stream<List<PeerDeviceModel>> getPeersStream();
}

class DiscoveryRemoteDataSourceImpl implements DiscoveryRemoteDataSource {
  final NetworkDiscovery networkDiscovery;
  final NetworkManager networkManager;

  DiscoveryRemoteDataSourceImpl(this.networkDiscovery, this.networkManager);

  @override
  Future<List<PeerDeviceModel>> scanNetwork() async {
    try {
      if (!networkManager.isConnected) {
        throw NetworkException('Not connected to network');
      }

      // Wait for discovery to find peers
      await Future.delayed(const Duration(seconds: 2));

      final peers = networkDiscovery.discoveredPeers;
      return peers.map((peer) => PeerDeviceModel.fromEntity(peer)).toList();
    } catch (e) {
      throw NetworkException('Failed to scan network: $e');
    }
  }

  @override
  Future<bool> broadcastPresence() async {
    try {
      if (!networkManager.isConnected) {
        throw NetworkException('Not connected to network');
      }

      // Presence is already being broadcast by NetworkDiscovery
      return true;
    } catch (e) {
      throw NetworkException('Failed to broadcast presence: $e');
    }
  }

  @override
  Stream<List<PeerDeviceModel>> getPeersStream() {
    return Stream.periodic(const Duration(seconds: 1), (_) {
      final peers = networkDiscovery.discoveredPeers;
      return peers.map((peer) => PeerDeviceModel.fromEntity(peer)).toList();
    });
  }
}
