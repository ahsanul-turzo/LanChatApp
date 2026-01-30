import 'message.dart';

class Conversation {
  final String id;
  final String peerId;
  final String peerName;
  final String? peerAvatar;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;
  final bool isOnline;

  Conversation({
    required this.id,
    required this.peerId,
    required this.peerName,
    this.peerAvatar,
    this.lastMessage,
    this.unreadCount = 0,
    required this.updatedAt,
    this.isOnline = false,
  });

  Conversation copyWith({
    String? id,
    String? peerId,
    String? peerName,
    String? peerAvatar,
    Message? lastMessage,
    int? unreadCount,
    DateTime? updatedAt,
    bool? isOnline,
  }) {
    return Conversation(
      id: id ?? this.id,
      peerId: peerId ?? this.peerId,
      peerName: peerName ?? this.peerName,
      peerAvatar: peerAvatar ?? this.peerAvatar,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      updatedAt: updatedAt ?? this.updatedAt,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
