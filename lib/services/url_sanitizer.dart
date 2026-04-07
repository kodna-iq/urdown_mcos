/// Sanitizes and validates URLs before passing them to yt-dlp.
class UrlSanitizer {
  UrlSanitizer._();

  /// Strips leading/trailing whitespace and common garbage characters.
  static String sanitize(String rawUrl) {
    var url = rawUrl.trim();

    // Remove surrounding quotes or angle-brackets sometimes copied from terminals
    if ((url.startsWith('"') && url.endsWith('"')) ||
        (url.startsWith("'") && url.endsWith("'"))) {
      url = url.substring(1, url.length - 1).trim();
    }
    if (url.startsWith('<') && url.endsWith('>')) {
      url = url.substring(1, url.length - 1).trim();
    }

    return url;
  }

  /// Returns true if [url] looks like a valid http/https URL.
  static bool isValid(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return false;
    final lower = trimmed.toLowerCase();
    return lower.startsWith('http://') || lower.startsWith('https://');
  }
}
