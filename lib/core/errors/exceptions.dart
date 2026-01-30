class ServerException implements Exception {
  final String message;
  final String? code;

  ServerException(this.message, [this.code]);

  @override
  String toString() => 'ServerException: $message';
}

class NetworkException implements Exception {
  final String message;
  final String? code;

  NetworkException(this.message, [this.code]);

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;

  CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

class SocketException implements Exception {
  final String message;

  SocketException(this.message);

  @override
  String toString() => 'SocketException: $message';
}

class FileException implements Exception {
  final String message;

  FileException(this.message);

  @override
  String toString() => 'FileException: $message';
}
