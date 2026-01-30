class UserProfile {
  final String id;
  final String userName;
  final String deviceName;
  final String? avatarUrl;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.userName,
    required this.deviceName,
    this.avatarUrl,
    this.status = 'Available',
    required this.createdAt,
    required this.updatedAt,
  });

  UserProfile copyWith({
    String? id,
    String? userName,
    String? deviceName,
    String? avatarUrl,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      deviceName: deviceName ?? this.deviceName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
