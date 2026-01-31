import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lan_chat_app/features/chat/domain/entities/attachment.dart';
import 'package:lan_chat_app/features/chat/domain/entities/message.dart';

import '../../../../core/constants/network_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/socket_service.dart';
import '../models/attachment_model.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<MessageModel> sendMessage(MessageModel message);
  Future<MessageModel> sendFile(MessageModel message, AttachmentModel attachment);
  Stream<MessageModel> receiveMessages();
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final SocketService socketService;
  final StreamController<MessageModel> _messageStreamController = StreamController<MessageModel>.broadcast();

  ChatRemoteDataSourceImpl(this.socketService) {
    _listenToMessages();
  }

  void _listenToMessages() {
    socketService.messageStream.listen((data) {
      final msgType = data['type'] as String?;

      if (msgType == NetworkConstants.msgTypeText ||
          msgType == NetworkConstants.msgTypeImage ||
          msgType == NetworkConstants.msgTypeFile) {
        try {
          final message = MessageModel.fromJson(data);
          _messageStreamController.add(message);
        } catch (e) {
          debugPrint('Error parsing incoming message: $e');
        }
      }
    });
  }

  @override
  Future<MessageModel> sendMessage(MessageModel message) async {
    try {
      if (!socketService.isConnected) {
        throw NetworkException('Not connected to peer');
      }

      final messageData = message.toJson();
      messageData['type'] = NetworkConstants.msgTypeText;

      debugPrint('📤 Sending message: $messageData');
      socketService.sendMessage(messageData);

      return MessageModel.fromEntity(message.copyWith(status: MessageStatus.sent));
    } catch (e) {
      throw NetworkException('Failed to send message: $e');
    }
  }

  @override
  Future<MessageModel> sendFile(MessageModel message, AttachmentModel attachment) async {
    try {
      if (!socketService.isConnected) {
        throw NetworkException('Not connected to peer');
      }

      final messageData = message.toJson();
      messageData['type'] = attachment.type == AttachmentType.image
          ? NetworkConstants.msgTypeImage
          : NetworkConstants.msgTypeFile;
      messageData['attachment'] = attachment.toJson();

      socketService.sendMessage(messageData);

      return message.copyWith(status: MessageStatus.sent) as MessageModel;
    } catch (e) {
      throw NetworkException('Failed to send file: $e');
    }
  }

  @override
  Stream<MessageModel> receiveMessages() {
    return _messageStreamController.stream;
  }

  void dispose() {
    _messageStreamController.close();
  }
}
