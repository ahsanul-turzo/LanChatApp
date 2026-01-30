import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/attachment.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';

abstract class ChatRepository {
  Future<Either<Failure, Message>> sendMessage(Message message);
  Future<Either<Failure, Message>> sendFile(Message message, Attachment attachment);
  Stream<Message> receiveMessages();
  Future<Either<Failure, List<Message>>> getMessages(String peerId);
  Future<Either<Failure, List<Conversation>>> getConversations();
  Future<Either<Failure, bool>> markAsRead(String messageId);
  Future<Either<Failure, bool>> deleteMessage(String messageId);
  Future<Either<Failure, bool>> deleteConversation(String conversationId);
}
