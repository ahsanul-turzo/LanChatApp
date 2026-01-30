import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class SendMessage {
  final ChatRepository repository;

  SendMessage(this.repository);

  Future<Either<Failure, Message>> call(Message message) async {
    return await repository.sendMessage(message);
  }
}
