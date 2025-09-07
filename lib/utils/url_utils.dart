/// Utility class for handling URL extraction and validation
class UrlUtils {
  /// Extract URL from text that might contain both text and URLs
  static String? extractUrlFromText(String text) {
    if (text.trim().isEmpty) return null;

    // Common URL patterns
    final urlPatterns = [
      // HTTP/HTTPS URLs
      RegExp(r'https?://[^\s]+', caseSensitive: false),
      // URLs without protocol
      RegExp(
          r'(?:www\.)?[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}[^\s]*',
          caseSensitive: false),
    ];

    // Try to find URLs using regex patterns
    for (final pattern in urlPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        String url = match.group(0)!;

        // Clean up the URL
        url = _cleanUrl(url);

        // Add protocol if missing
        if (!url.startsWith('http')) {
          url = 'https://$url';
        }

        return url;
      }
    }

    // If no regex match, check if the entire text looks like a URL
    final trimmed = text.trim();
    if (_looksLikeUrl(trimmed)) {
      String url = trimmed;
      if (!url.startsWith('http')) {
        url = 'https://$url';
      }
      return _cleanUrl(url);
    }

    return null;
  }

  /// Clean URL by removing common unwanted characters at the end
  static String _cleanUrl(String url) {
    // Remove common punctuation that might be included accidentally
    final cleanPatterns = [
      RegExp(r'[.,;:!?\x27\x22)\]}>]+$'), // Remove trailing punctuation
      RegExp(r'\s+$'), // Remove trailing whitespace
    ];

    String cleaned = url;
    for (final pattern in cleanPatterns) {
      cleaned = cleaned.replaceAll(pattern, '');
    }

    return cleaned;
  }

  /// Check if text looks like a URL
  static bool _looksLikeUrl(String text) {
    if (text.isEmpty) return false;

    // Check for common domain patterns
    final domainPattern = RegExp(
      r'^(?:https?://)?(?:www\.)?[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}',
      caseSensitive: false,
    );

    return domainPattern.hasMatch(text);
  }

  /// Validate if a URL is properly formatted
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  /// Get domain from URL for display purposes
  static String? getDomainFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return null;
    }
  }
}
