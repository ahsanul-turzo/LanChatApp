import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, UserProfile>> getProfile() async {
    try {
      final profile = await localDataSource.getProfile();
      return Right(profile.toEntity());
    } on CacheException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(StorageFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateProfile(UserProfile profile) async {
    try {
      final profileModel = UserProfileModel.fromEntity(profile);
      final savedProfile = await localDataSource.saveProfile(profileModel);
      return Right(savedProfile.toEntity());
    } on CacheException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(StorageFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasProfile() async {
    try {
      final hasProfile = await localDataSource.hasProfile();
      return Right(hasProfile);
    } catch (e) {
      return Left(StorageFailure('Unexpected error: $e'));
    }
  }
}
