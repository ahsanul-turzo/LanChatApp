import 'dart:async';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/attachment.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_local_datasource.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/attachment_model.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatLocalDataSource localDataSource;
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.localDataSource, required this.remoteDataSource});

  @override
  Future<Either<Failure, Message>> sendMessage(Message message) async {
    try {
      final messageModel = MessageModel.fromEntity(message);
      final sentMessage = await remoteDataSource.sendMessage(messageModel);
      await localDataSource.saveMessage(sentMessage);
      return Right(sentMessage.toEntity());
    } on NetworkException catch (e) {
      return Left(MessageFailure(e.message));
    } catch (e) {
      return Left(MessageFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Message>> sendFile(Message message, Attachment attachment) async {
    try {
      final messageModel = MessageModel.fromEntity(message);
      final attachmentModel = AttachmentModel.fromEntity(attachment);

      final sentMessage = await remoteDataSource.sendFile(messageModel, attachmentModel);

      await localDataSource.saveMessage(sentMessage);
      return Right(sentMessage.toEntity());
    } on NetworkException catch (e) {
      return Left(FileTransferFailure(e.message));
    } catch (e) {
      return Left(FileTransferFailure('Unexpected error: $e'));
    }
  }

  @override
  Stream<Message> receiveMessages() {
    return remoteDataSource.receiveMessages().map((model) => model.toEntity());
  }

  @override
  Future<Either<Failure, List<Message>>> getMessages(String peerId) async {
    try {
      final messages = await localDataSource.getMessages(peerId);
      return Right(messages.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(StorageFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Conversation>>> getConversations() async {
    try {
      final conversations = await localDataSource.getConversations();
      return Right(conversations.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(StorageFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> markAsRead(String messageId) async {
    try {
      final result = await localDataSource.markAsRead(messageId);
      return Right(result);
    } on CacheException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(StorageFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteMessage(String messageId) async {
    try {
      final result = await localDataSource.deleteMessage(messageId);
      return Right(result);
    } on CacheException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(StorageFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteConversation(String conversationId) async {
    try {
      final result = await localDataSource.deleteConversation(conversationId);
      return Right(result);
    } on CacheException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(StorageFailure('Unexpected error: $e'));
    }
  }
}
