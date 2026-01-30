import 'package:get_storage/get_storage.dart';
import 'package:lan_chat_app/features/profile/data/models/user_profile_model.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/errors/exceptions.dart';

abstract class ProfileLocalDataSource {
  Future<UserProfileModel> getProfile();
  Future<UserProfileModel> saveProfile(UserProfileModel profile);
  Future<bool> hasProfile();
  Future<bool> deleteProfile();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final GetStorage storage;

  ProfileLocalDataSourceImpl(this.storage);

  @override
  Future<UserProfileModel> getProfile() async {
    try {
      final data = storage.read(AppConstants.storageKeyProfile);
      if (data == null) {
        throw CacheException('No profile found');
      }
      return UserProfileModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw CacheException('Failed to get profile: $e');
    }
  }

  @override
  Future<UserProfileModel> saveProfile(UserProfileModel profile) async {
    try {
      await storage.write(AppConstants.storageKeyProfile, profile.toJson());
      return profile;
    } catch (e) {
      throw CacheException('Failed to save profile: $e');
    }
  }

  @override
  Future<bool> hasProfile() async {
    try {
      return storage.hasData(AppConstants.storageKeyProfile);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteProfile() async {
    try {
      await storage.remove(AppConstants.storageKeyProfile);
      return true;
    } catch (e) {
      throw CacheException('Failed to delete profile: $e');
    }
  }
}
