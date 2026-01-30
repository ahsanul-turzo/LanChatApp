class PeerDevice {
  final String id;
  final String ipAddress;
  final String deviceName;
  final String userName;
  final bool isOnline;
  final DateTime lastSeen;
  final String? avatarUrl;
  final int? port;

  PeerDevice({
    required this.id,
    required this.ipAddress,
    required this.deviceName,
    required this.userName,
    required this.isOnline,
    required this.lastSeen,
    this.avatarUrl,
    this.port,
  });

  PeerDevice copyWith({
    String? id,
    String? ipAddress,
    String? deviceName,
    String? userName,
    bool? isOnline,
    DateTime? lastSeen,
    String? avatarUrl,
    int? port,
  }) {
    return PeerDevice(
      id: id ?? this.id,
      ipAddress: ipAddress ?? this.ipAddress,
      deviceName: deviceName ?? this.deviceName,
      userName: userName ?? this.userName,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      port: port ?? this.port,
    );
  }
}
