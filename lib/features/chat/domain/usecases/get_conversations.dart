import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/conversation.dart';
import '../repositories/chat_repository.dart';

class GetConversations {
  final ChatRepository repository;

  GetConversations(this.repository);

  Future<Either<Failure, List<Conversation>>> call() async {
    return await repository.getConversations();
  }
}
