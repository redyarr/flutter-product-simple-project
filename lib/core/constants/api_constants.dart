abstract final class ApiConstants {
  // Overridable at build time via `--dart-define=API_BASE_URL=...`.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://dummyjson.com',
  );

  static const Duration timeout = Duration(seconds: 10);
  static const Duration searchDebounce = Duration(milliseconds: 300);
  static const int maxSearchLength = 100;
  static const String defaultCatalogLimit = '30';

  // Use Uri.https instead of string concatenation to enforce HTTPS and query encoding.
  static Uri buildUri(String path, [Map<String, String>? queryParameters]) {
    final Uri parsed = Uri.parse(baseUrl);
    if (parsed.scheme != 'https' || parsed.authority.isEmpty) {
      throw const FormatException('API_BASE_URL must be a valid HTTPS URL.');
    }

    final String resolvedPath = parsed.path.isEmpty || parsed.path == '/'
        ? path
        : <String>[
            ...parsed.pathSegments.where((String segment) => segment.isNotEmpty),
            ...path.split('/').where((String segment) => segment.isNotEmpty),
          ].join('/');

    return Uri.https(parsed.authority, resolvedPath, queryParameters);
  }
}
