import 'dart:async';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../utils/url_utils.dart';

/// Service for receiving shared content from other apps
class ShareReceiveService {
  static final ShareReceiveService _instance = ShareReceiveService._internal();
  factory ShareReceiveService() => _instance;
  ShareReceiveService._internal();

  StreamSubscription? _intentSubscription;
  final _sharedContentController = StreamController<SharedContent>.broadcast();

  /// Stream of shared content
  Stream<SharedContent> get sharedContentStream => _sharedContentController.stream;

  /// Initialize the share receive service
  Future<void> initialize() async {
    // Handle shared content when app is opened from share
    final initialMedia = await ReceiveSharingIntent.instance.getInitialMedia();
    if (initialMedia.isNotEmpty) {
      _processSharedMedia(initialMedia);
    }

    // Listen for shared content while app is running
    _intentSubscription = ReceiveSharingIntent.instance.getMediaStream().listen(
      _processSharedMedia,
      onError: (err) {
        // Handle error
      },
    );
  }

  /// Process shared media files
  void _processSharedMedia(List<SharedMediaFile> files) {
    for (final file in files) {
      if (file.type == SharedMediaType.url || file.type == SharedMediaType.text) {
        final text = file.path;
        final urls = UrlUtils.extractUrls(text);
        
        if (urls.isNotEmpty) {
          for (final url in urls) {
            _sharedContentController.add(
              SharedContent(
                url: url,
                text: text != url ? text : null,
                source: _detectSourceFromUrl(url),
              ),
            );
          }
        } else if (text.isNotEmpty) {
          // Text shared without URL
          _sharedContentController.add(
            SharedContent(
              text: text,
              source: SharedContentSource.unknown,
            ),
          );
        }
      }
    }
    
    // Clear the intent after processing
    ReceiveSharingIntent.instance.reset();
  }

  /// Detect the source app from URL
  SharedContentSource _detectSourceFromUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return SharedContentSource.unknown;

    final host = uri.host.toLowerCase();

    if (host.contains('twitter.com') || host.contains('x.com')) {
      return SharedContentSource.twitter;
    } else if (host.contains('instagram.com')) {
      return SharedContentSource.instagram;
    } else if (host.contains('youtube.com') || host.contains('youtu.be')) {
      return SharedContentSource.youtube;
    } else if (host.contains('tiktok.com')) {
      return SharedContentSource.tiktok;
    } else if (host.contains('reddit.com')) {
      return SharedContentSource.reddit;
    } else if (host.contains('linkedin.com')) {
      return SharedContentSource.linkedin;
    } else if (host.contains('facebook.com') || host.contains('fb.com')) {
      return SharedContentSource.facebook;
    } else if (host.contains('pinterest.com')) {
      return SharedContentSource.pinterest;
    } else if (host.contains('medium.com')) {
      return SharedContentSource.medium;
    } else if (host.contains('spotify.com')) {
      return SharedContentSource.spotify;
    } else {
      return SharedContentSource.web;
    }
  }

  /// Dispose the service
  void dispose() {
    _intentSubscription?.cancel();
    _sharedContentController.close();
  }
}

/// Model for shared content
class SharedContent {
  final String? url;
  final String? text;
  final SharedContentSource source;

  SharedContent({
    this.url,
    this.text,
    required this.source,
  });

  bool get hasUrl => url != null && url!.isNotEmpty;
  bool get hasText => text != null && text!.isNotEmpty;
}

/// Source of shared content
enum SharedContentSource {
  twitter,
  instagram,
  youtube,
  tiktok,
  reddit,
  linkedin,
  facebook,
  pinterest,
  medium,
  spotify,
  web,
  unknown,
}
