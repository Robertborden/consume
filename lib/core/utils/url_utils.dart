import 'package:consume/domain/entities/enums/content_source.dart';

class UrlUtils {
  UrlUtils._();

  /// Extract URL from text (handles shared text with extra content)
  static String? extractUrl(String text) {
    final urlRegex = RegExp(
      r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
      caseSensitive: false,
    );
    final match = urlRegex.firstMatch(text);
    return match?.group(0);
  }

  /// Detect content source from URL
  static ContentSource detectSource(String url) {
    final lowerUrl = url.toLowerCase();

    if (lowerUrl.contains('instagram.com') || lowerUrl.contains('instagr.am')) {
      return ContentSource.instagram;
    }
    if (lowerUrl.contains('tiktok.com') || lowerUrl.contains('vm.tiktok.com')) {
      return ContentSource.tiktok;
    }
    if (lowerUrl.contains('youtube.com') || lowerUrl.contains('youtu.be')) {
      return ContentSource.youtube;
    }
    if (lowerUrl.contains('twitter.com') || lowerUrl.contains('x.com')) {
      return ContentSource.twitter;
    }
    if (lowerUrl.contains('reddit.com') || lowerUrl.contains('redd.it')) {
      return ContentSource.reddit;
    }
    if (lowerUrl.contains('linkedin.com')) {
      return ContentSource.linkedin;
    }
    if (lowerUrl.contains('facebook.com') || lowerUrl.contains('fb.com')) {
      return ContentSource.facebook;
    }
    if (lowerUrl.contains('pinterest.com') || lowerUrl.contains('pin.it')) {
      return ContentSource.pinterest;
    }

    // Check for common article domains
    if (_isArticleDomain(lowerUrl)) {
      return ContentSource.article;
    }

    return ContentSource.other;
  }

  static bool _isArticleDomain(String url) {
    final articleDomains = [
      'medium.com',
      'dev.to',
      'substack.com',
      'news.ycombinator.com',
      'techcrunch.com',
      'theverge.com',
      'wired.com',
      'arstechnica.com',
      'bbc.com',
      'cnn.com',
      'nytimes.com',
      'theguardian.com',
      'washingtonpost.com',
    ];

    return articleDomains.any((domain) => url.contains(domain));
  }

  /// Get domain from URL
  static String? getDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (_) {
      return null;
    }
  }

  /// Clean URL (remove tracking parameters)
  static String cleanUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final cleanParams = Map<String, String>.from(uri.queryParameters);

      // Remove common tracking parameters
      final trackingParams = [
        'utm_source',
        'utm_medium',
        'utm_campaign',
        'utm_content',
        'utm_term',
        'fbclid',
        'gclid',
        'ref',
        'source',
      ];

      for (final param in trackingParams) {
        cleanParams.remove(param);
      }

      return uri.replace(queryParameters: cleanParams.isEmpty ? null : cleanParams).toString();
    } catch (_) {
      return url;
    }
  }
}
