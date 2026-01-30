import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/peer_device.dart';

abstract class DiscoveryRepository {
  Future<Either<Failure, List<PeerDevice>>> scanNetwork();
  Future<Either<Failure, bool>> broadcastPresence();
  Stream<List<PeerDevice>> getPeersStream();
  Future<Either<Failure, List<PeerDevice>>> getCachedPeers();
}
