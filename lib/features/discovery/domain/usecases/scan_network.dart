import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/peer_device.dart';
import '../repositories/discovery_repository.dart';

class ScanNetwork {
  final DiscoveryRepository repository;

  ScanNetwork(this.repository);

  Future<Either<Failure, List<PeerDevice>>> call() async {
    return await repository.scanNetwork();
  }
}
