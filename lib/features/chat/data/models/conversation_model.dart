import '../../domain/entities/conversation.dart';
import 'message_model.dart';

class ConversationModel extends Conversation {
  ConversationModel({
    required super.id,
    required super.peerId,
    required super.peerName,
    super.peerAvatar,
    super.lastMessage,
    super.unreadCount,
    required super.updatedAt,
    super.isOnline,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      peerId: json['peerId'] as String,
      peerName: json['peerName'] as String,
      peerAvatar: json['peerAvatar'] as String?,
      lastMessage: json['lastMessage'] != null
          ? MessageModel.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unreadCount'] as int? ?? 0,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isOnline: json['isOnline'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'peerId': peerId,
      'peerName': peerName,
      'peerAvatar': peerAvatar,
      'lastMessage': lastMessage != null ? MessageModel.fromEntity(lastMessage!).toJson() : null,
      'unreadCount': unreadCount,
      'updatedAt': updatedAt.toIso8601String(),
      'isOnline': isOnline,
    };
  }

  factory ConversationModel.fromEntity(Conversation entity) {
    return ConversationModel(
      id: entity.id,
      peerId: entity.peerId,
      peerName: entity.peerName,
      peerAvatar: entity.peerAvatar,
      lastMessage: entity.lastMessage,
      unreadCount: entity.unreadCount,
      updatedAt: entity.updatedAt,
      isOnline: entity.isOnline,
    );
  }

  Conversation toEntity() {
    return Conversation(
      id: id,
      peerId: peerId,
      peerName: peerName,
      peerAvatar: peerAvatar,
      lastMessage: lastMessage,
      unreadCount: unreadCount,
      updatedAt: updatedAt,
      isOnline: isOnline,
    );
  }
}
