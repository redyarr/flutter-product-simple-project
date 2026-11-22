import 'package:flutter_testapp/core/constants/api_constants.dart';

abstract final class InputSanitizer {
  static final RegExp _multiWhitespace = RegExp(r'\s+');

  static String sanitizeSearchQuery(String raw) {
    final String normalized = raw.trim().replaceAll(_multiWhitespace, ' ');
    if (normalized.length <= ApiConstants.maxSearchLength) {
      return normalized;
    }
    return normalized.substring(0, ApiConstants.maxSearchLength).trimRight();
  }
}
