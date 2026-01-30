import '../../domain/entities/peer_device.dart';

class PeerDeviceModel extends PeerDevice {
  PeerDeviceModel({
    required super.id,
    required super.ipAddress,
    required super.deviceName,
    required super.userName,
    required super.isOnline,
    required super.lastSeen,
    super.avatarUrl,
    super.port,
  });

  factory PeerDeviceModel.fromJson(Map<String, dynamic> json) {
    return PeerDeviceModel(
      id: json['id'] as String,
      ipAddress: json['ipAddress'] as String,
      deviceName: json['deviceName'] as String,
      userName: json['userName'] as String,
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeen: DateTime.parse(json['lastSeen'] as String),
      avatarUrl: json['avatarUrl'] as String?,
      port: json['port'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ipAddress': ipAddress,
      'deviceName': deviceName,
      'userName': userName,
      'isOnline': isOnline,
      'lastSeen': lastSeen.toIso8601String(),
      'avatarUrl': avatarUrl,
      'port': port,
    };
  }

  factory PeerDeviceModel.fromEntity(PeerDevice entity) {
    return PeerDeviceModel(
      id: entity.id,
      ipAddress: entity.ipAddress,
      deviceName: entity.deviceName,
      userName: entity.userName,
      isOnline: entity.isOnline,
      lastSeen: entity.lastSeen,
      avatarUrl: entity.avatarUrl,
      port: entity.port,
    );
  }

  PeerDevice toEntity() {
    return PeerDevice(
      id: id,
      ipAddress: ipAddress,
      deviceName: deviceName,
      userName: userName,
      isOnline: isOnline,
      lastSeen: lastSeen,
      avatarUrl: avatarUrl,
      port: port,
    );
  }
}
