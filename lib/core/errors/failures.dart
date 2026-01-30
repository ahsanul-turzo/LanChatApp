abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.code]);
}

class ConnectionFailure extends Failure {
  const ConnectionFailure(super.message, [super.code]);
}

class MessageFailure extends Failure {
  const MessageFailure(super.message, [super.code]);
}

class StorageFailure extends Failure {
  const StorageFailure(super.message, [super.code]);
}

class FileTransferFailure extends Failure {
  const FileTransferFailure(super.message, [super.code]);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.code]);
}
