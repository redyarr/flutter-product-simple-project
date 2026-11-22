abstract final class UrlValidator {
  static bool isValidHttpsUrl(String? rawUrl) {
    if (rawUrl == null) {
      return false;
    }
    final String trimmed = rawUrl.trim();
    if (!trimmed.startsWith('https://')) {
      return false;
    }
    final Uri? parsed = Uri.tryParse(trimmed);
    return parsed != null &&
        parsed.scheme == 'https' &&
        parsed.host.isNotEmpty;
  }
}
