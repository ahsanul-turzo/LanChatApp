import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/discovery_repository.dart';

class BroadcastPresence {
  final DiscoveryRepository repository;

  BroadcastPresence(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.broadcastPresence();
  }
}
