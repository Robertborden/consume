import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../utils/url_utils.dart';

/// Service for fetching URL metadata (title, description, image)
class UrlMetadataService {
  static final UrlMetadataService _instance = UrlMetadataService._internal();
  factory UrlMetadataService() => _instance;
  UrlMetadataService._internal();

  final _cache = <String, UrlMetadata>{};
  final _client = http.Client();

  /// Fetch metadata for a URL
  Future<UrlMetadata> fetchMetadata(String url) async {
    // Check cache first
    if (_cache.containsKey(url)) {
      return _cache[url]!;
    }

    try {
      final cleanUrl = UrlUtils.cleanUrl(url);
      final response = await _client.get(
        Uri.parse(cleanUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (compatible; ConsumeApp/1.0)',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final metadata = _parseHtmlMetadata(response.body, cleanUrl);
        _cache[url] = metadata;
        return metadata;
      }
    } catch (e) {
      // Return basic metadata on error
    }

    // Return basic metadata if fetch fails
    final basicMetadata = UrlMetadata(
      url: url,
      title: _extractDomainName(url),
      source: UrlUtils.detectSource(url),
    );
    _cache[url] = basicMetadata;
    return basicMetadata;
  }

  /// Parse HTML to extract metadata
  UrlMetadata _parseHtmlMetadata(String html, String url) {
    final document = html_parser.parse(html);

    // Try to get Open Graph metadata first
    String? title = _getMetaContent(document, 'og:title');
    String? description = _getMetaContent(document, 'og:description');
    String? image = _getMetaContent(document, 'og:image');
    String? siteName = _getMetaContent(document, 'og:site_name');

    // Fall back to Twitter Card metadata
    title ??= _getMetaContent(document, 'twitter:title');
    description ??= _getMetaContent(document, 'twitter:description');
    image ??= _getMetaContent(document, 'twitter:image');

    // Fall back to standard HTML elements
    title ??= document.querySelector('title')?.text;
    description ??= _getMetaContent(document, 'description', isProperty: false);

    // Get favicon
    String? favicon = _getFavicon(document, url);

    // Clean up values
    title = title?.trim();
    description = description?.trim();

    // Limit description length
    if (description != null && description.length > 300) {
      description = '${description.substring(0, 297)}...';
    }

    // Make image URL absolute if relative
    if (image != null && !image.startsWith('http')) {
      final uri = Uri.parse(url);
      if (image.startsWith('//')) {
        image = '${uri.scheme}:$image';
      } else if (image.startsWith('/')) {
        image = '${uri.scheme}://${uri.host}$image';
      } else {
        image = '${uri.scheme}://${uri.host}/$image';
      }
    }

    return UrlMetadata(
      url: url,
      title: title ?? _extractDomainName(url),
      description: description,
      thumbnailUrl: image,
      faviconUrl: favicon,
      siteName: siteName,
      source: UrlUtils.detectSource(url),
    );
  }

  /// Get meta tag content
  String? _getMetaContent(
    dynamic document,
    String name, {
    bool isProperty = true,
  }) {
    final attribute = isProperty ? 'property' : 'name';
    final element = document.querySelector('meta[$attribute="$name"]');
    return element?.attributes['content'];
  }

  /// Get favicon URL
  String? _getFavicon(dynamic document, String url) {
    // Try various favicon link elements
    final selectors = [
      'link[rel="icon"]',
      'link[rel="shortcut icon"]',
      'link[rel="apple-touch-icon"]',
      'link[rel="apple-touch-icon-precomposed"]',
    ];

    for (final selector in selectors) {
      final element = document.querySelector(selector);
      if (element != null) {
        final href = element.attributes['href'];
        if (href != null) {
          if (href.startsWith('http')) {
            return href;
          } else {
            final uri = Uri.parse(url);
            if (href.startsWith('//')) {
              return '${uri.scheme}:$href';
            } else if (href.startsWith('/')) {
              return '${uri.scheme}://${uri.host}$href';
            } else {
              return '${uri.scheme}://${uri.host}/$href';
            }
          }
        }
      }
    }

    // Default to domain/favicon.ico
    final uri = Uri.parse(url);
    return '${uri.scheme}://${uri.host}/favicon.ico';
  }

  /// Extract domain name from URL
  String _extractDomainName(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host;
      // Remove www. prefix
      return host.startsWith('www.') ? host.substring(4) : host;
    } catch (e) {
      return url;
    }
  }

  /// Clear the cache
  void clearCache() {
    _cache.clear();
  }

  /// Dispose the service
  void dispose() {
    _client.close();
  }
}

/// Model for URL metadata
class UrlMetadata {
  final String url;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final String? faviconUrl;
  final String? siteName;
  final String source;

  UrlMetadata({
    required this.url,
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.faviconUrl,
    this.siteName,
    required this.source,
  });

  Map<String, dynamic> toJson() => {
    'url': url,
    'title': title,
    'description': description,
    'thumbnail_url': thumbnailUrl,
    'favicon_url': faviconUrl,
    'site_name': siteName,
    'source': source,
  };
}
