import 'package:equatable/equatable.dart';

// Only user-safe messages cross into UI state; raw exceptions stay in data/.
sealed class Failure extends Equatable {
  const Failure(this.userMessage);

  final String userMessage;

  @override
  List<Object?> get props => <Object?>[userMessage];
}

final class NetworkFailure extends Failure {
  const NetworkFailure([
    super.userMessage =
        'Unable to reach the catalog service. Please check your connection and try again.',
  ]);
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure([
    super.userMessage =
        'The catalog request timed out. Please try again in a moment.',
  ]);
}

final class ServerFailure extends Failure {
  const ServerFailure([
    super.userMessage =
        'The catalog service is temporarily unavailable. Please try again shortly.',
  ]);
}

final class DataParsingFailure extends Failure {
  const DataParsingFailure([
    super.userMessage =
        'We received an unexpected catalog response. Please try again.',
  ]);
}
