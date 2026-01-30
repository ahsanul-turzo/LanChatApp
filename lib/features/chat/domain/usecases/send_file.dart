import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/attachment.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class SendFile {
  final ChatRepository repository;

  SendFile(this.repository);

  Future<Either<Failure, Message>> call(Message message, Attachment attachment) async {
    return await repository.sendFile(message, attachment);
  }
}
