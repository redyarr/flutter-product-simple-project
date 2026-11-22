sealed class AppException implements Exception {
  const AppException([this.message = '']);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class NetworkException extends AppException {
  const NetworkException([super.message]);
}

final class TimeoutException extends AppException {
  const TimeoutException([super.message]);
}

final class ServerException extends AppException {
  const ServerException({required this.statusCode, String message = ''})
      : super(message);

  final int statusCode;
}

final class DataParsingException extends AppException {
  const DataParsingException([super.message]);
}
