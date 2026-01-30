import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  UserProfileModel({
    required super.id,
    required super.userName,
    required super.deviceName,
    super.avatarUrl,
    super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      userName: json['userName'] as String,
      deviceName: json['deviceName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      status: json['status'] as String? ?? 'Available',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'deviceName': deviceName,
      'avatarUrl': avatarUrl,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfileModel.fromEntity(UserProfile entity) {
    return UserProfileModel(
      id: entity.id,
      userName: entity.userName,
      deviceName: entity.deviceName,
      avatarUrl: entity.avatarUrl,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      userName: userName,
      deviceName: deviceName,
      avatarUrl: avatarUrl,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
