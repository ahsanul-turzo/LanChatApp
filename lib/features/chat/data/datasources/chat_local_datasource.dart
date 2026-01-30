import 'package:get_storage/get_storage.dart';
import 'package:lan_chat_app/features/chat/domain/entities/message.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

abstract class ChatLocalDataSource {
  Future<List<MessageModel>> getMessages(String peerId);
  Future<MessageModel> saveMessage(MessageModel message);
  Future<List<MessageModel>> saveMessages(List<MessageModel> messages);
  Future<List<ConversationModel>> getConversations();
  Future<ConversationModel> saveConversation(ConversationModel conversation);
  Future<bool> deleteMessage(String messageId);
  Future<bool> deleteConversation(String conversationId);
  Future<bool> markAsRead(String messageId);
  Future<int> getUnreadCount(String peerId);
}

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  final GetStorage storage;

  ChatLocalDataSourceImpl(this.storage);

  String _getMessagesKey(String peerId) => 'messages_$peerId';
  String _getConversationsKey() => AppConstants.storageKeyConversations;

  @override
  Future<List<MessageModel>> getMessages(String peerId) async {
    try {
      final data = storage.read(_getMessagesKey(peerId));
      if (data == null) return [];

      final List<dynamic> jsonList = data as List<dynamic>;
      return jsonList.map((json) => MessageModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw CacheException('Failed to get messages: $e');
    }
  }

  @override
  Future<MessageModel> saveMessage(MessageModel message) async {
    try {
      final messages = await getMessages(message.receiverId);
      messages.add(message);

      final jsonList = messages.map((msg) => msg.toJson()).toList();
      await storage.write(_getMessagesKey(message.receiverId), jsonList);

      return message;
    } catch (e) {
      throw CacheException('Failed to save message: $e');
    }
  }

  @override
  Future<List<MessageModel>> saveMessages(List<MessageModel> messages) async {
    try {
      if (messages.isEmpty) return messages;

      final peerId = messages.first.receiverId;
      final existingMessages = await getMessages(peerId);

      final allMessages = [...existingMessages, ...messages];
      final jsonList = allMessages.map((msg) => msg.toJson()).toList();
      await storage.write(_getMessagesKey(peerId), jsonList);

      return messages;
    } catch (e) {
      throw CacheException('Failed to save messages: $e');
    }
  }

  @override
  Future<List<ConversationModel>> getConversations() async {
    try {
      final data = storage.read(_getConversationsKey());
      if (data == null) return [];

      final List<dynamic> jsonList = data as List<dynamic>;
      return jsonList.map((json) => ConversationModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw CacheException('Failed to get conversations: $e');
    }
  }

  @override
  Future<ConversationModel> saveConversation(ConversationModel conversation) async {
    try {
      final conversations = await getConversations();

      final existingIndex = conversations.indexWhere((c) => c.id == conversation.id);

      if (existingIndex >= 0) {
        conversations[existingIndex] = conversation;
      } else {
        conversations.add(conversation);
      }

      conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      final jsonList = conversations.map((conv) => conv.toJson()).toList();
      await storage.write(_getConversationsKey(), jsonList);

      return conversation;
    } catch (e) {
      throw CacheException('Failed to save conversation: $e');
    }
  }

  @override
  Future<bool> deleteMessage(String messageId) async {
    try {
      final conversations = await getConversations();

      for (final conv in conversations) {
        final messages = await getMessages(conv.peerId);
        messages.removeWhere((msg) => msg.id == messageId);

        final jsonList = messages.map((msg) => msg.toJson()).toList();
        await storage.write(_getMessagesKey(conv.peerId), jsonList);
      }

      return true;
    } catch (e) {
      throw CacheException('Failed to delete message: $e');
    }
  }

  @override
  Future<bool> deleteConversation(String conversationId) async {
    try {
      final conversations = await getConversations();
      final conversation = conversations.firstWhere((c) => c.id == conversationId);

      await storage.remove(_getMessagesKey(conversation.peerId));

      conversations.removeWhere((c) => c.id == conversationId);
      final jsonList = conversations.map((conv) => conv.toJson()).toList();
      await storage.write(_getConversationsKey(), jsonList);

      return true;
    } catch (e) {
      throw CacheException('Failed to delete conversation: $e');
    }
  }

  @override
  Future<bool> markAsRead(String messageId) async {
    try {
      final conversations = await getConversations();

      for (final conv in conversations) {
        final messages = await getMessages(conv.peerId);
        final messageIndex = messages.indexWhere((msg) => msg.id == messageId);

        if (messageIndex >= 0) {
          messages[messageIndex] = MessageModel.fromEntity(messages[messageIndex].copyWith(status: MessageStatus.read));

          final jsonList = messages.map((msg) => msg.toJson()).toList();
          await storage.write(_getMessagesKey(conv.peerId), jsonList);
          return true;
        }
      }

      return false;
    } catch (e) {
      throw CacheException('Failed to mark as read: $e');
    }
  }

  @override
  Future<int> getUnreadCount(String peerId) async {
    try {
      final messages = await getMessages(peerId);
      return messages.where((msg) => msg.status != MessageStatus.read).length;
    } catch (e) {
      return 0;
    }
  }
}
