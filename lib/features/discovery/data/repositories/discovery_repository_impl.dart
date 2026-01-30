import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/peer_device.dart';
import '../../domain/repositories/discovery_repository.dart';
import '../datasources/discovery_local_datasource.dart';
import '../datasources/discovery_remote_datasource.dart';

class DiscoveryRepositoryImpl implements DiscoveryRepository {
  final DiscoveryLocalDataSource localDataSource;
  final DiscoveryRemoteDataSource remoteDataSource;

  DiscoveryRepositoryImpl({required this.localDataSource, required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PeerDevice>>> scanNetwork() async {
    try {
      final peers = await remoteDataSource.scanNetwork();
      await localDataSource.cachePeers(peers);
      return Right(peers.map((model) => model.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(NetworkFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> broadcastPresence() async {
    try {
      final result = await remoteDataSource.broadcastPresence();
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(NetworkFailure('Unexpected error: $e'));
    }
  }

  @override
  Stream<List<PeerDevice>> getPeersStream() {
    return remoteDataSource.getPeersStream().map((peers) => peers.map((model) => model.toEntity()).toList());
  }

  @override
  Future<Either<Failure, List<PeerDevice>>> getCachedPeers() async {
    try {
      final peers = await localDataSource.getCachedPeers();
      return Right(peers.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(StorageFailure('Unexpected error: $e'));
    }
  }
}
