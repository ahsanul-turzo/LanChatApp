import 'package:get/get.dart';

import '../../../../core/utils/encryption_utils.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_profile.dart';

class ProfileController extends GetxController {
  final GetProfile _getProfile = Get.find();
  final UpdateProfile _updateProfile = Get.find();

  final Rx<UserProfile?> _profile = Rx<UserProfile?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  UserProfile? get profile => _profile.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get hasProfile => _profile.value != null;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    _isLoading.value = true;
    _error.value = '';

    final result = await _getProfile();

    result.fold(
      (failure) {
        _error.value = failure.message;
        _profile.value = null;
      },
      (profile) {
        _profile.value = profile;
      },
    );

    _isLoading.value = false;
  }

  Future<bool> createProfile({required String userName, required String deviceName}) async {
    _isLoading.value = true;
    _error.value = '';

    final profileId = EncryptionUtils.generateMessageId();
    final now = DateTime.now();

    final newProfile = UserProfile(
      id: profileId,
      userName: userName,
      deviceName: deviceName,
      status: 'Available',
      createdAt: now,
      updatedAt: now,
    );

    final result = await _updateProfile(newProfile);

    result.fold(
      (failure) {
        _error.value = failure.message;
        _isLoading.value = false;
        return false;
      },
      (profile) {
        _profile.value = profile;
        _isLoading.value = false;
        return true;
      },
    );

    return result.isRight();
  }

  Future<bool> updateUserProfile({String? userName, String? deviceName, String? avatarUrl, String? status}) async {
    if (_profile.value == null) return false;

    _isLoading.value = true;
    _error.value = '';

    final updatedProfile = _profile.value!.copyWith(
      userName: userName,
      deviceName: deviceName,
      avatarUrl: avatarUrl,
      status: status,
      updatedAt: DateTime.now(),
    );

    final result = await _updateProfile(updatedProfile);

    result.fold(
      (failure) {
        _error.value = failure.message;
        _isLoading.value = false;
        return false;
      },
      (profile) {
        _profile.value = profile;
        _isLoading.value = false;
        return true;
      },
    );

    return result.isRight();
  }

  void clearError() {
    _error.value = '';
  }
}
