import 'package:flutter/material.dart';
import 'package:consume/core/theme/colors.dart';

/// Source platform of the saved content
enum ContentSource {
  instagram,
  tiktok,
  youtube,
  twitter,
  reddit,
  linkedin,
  facebook,
  pinterest,
  article,
  podcast,
  other;

  String get displayName {
    switch (this) {
      case ContentSource.instagram:
        return 'Instagram';
      case ContentSource.tiktok:
        return 'TikTok';
      case ContentSource.youtube:
        return 'YouTube';
      case ContentSource.twitter:
        return 'Twitter/X';
      case ContentSource.reddit:
        return 'Reddit';
      case ContentSource.linkedin:
        return 'LinkedIn';
      case ContentSource.facebook:
        return 'Facebook';
      case ContentSource.pinterest:
        return 'Pinterest';
      case ContentSource.article:
        return 'Article';
      case ContentSource.podcast:
        return 'Podcast';
      case ContentSource.other:
        return 'Other';
    }
  }

  /// Icon for the source
  IconData get icon {
    switch (this) {
      case ContentSource.instagram:
        return Icons.camera_alt;
      case ContentSource.tiktok:
        return Icons.music_video;
      case ContentSource.youtube:
        return Icons.play_circle_filled;
      case ContentSource.twitter:
        return Icons.alternate_email;
      case ContentSource.reddit:
        return Icons.forum;
      case ContentSource.linkedin:
        return Icons.business;
      case ContentSource.facebook:
        return Icons.facebook;
      case ContentSource.pinterest:
        return Icons.push_pin;
      case ContentSource.article:
        return Icons.article;
      case ContentSource.podcast:
        return Icons.podcasts;
      case ContentSource.other:
        return Icons.link;
    }
  }

  /// Brand color for the source
  Color get color {
    switch (this) {
      case ContentSource.instagram:
        return AppColors.instagram;
      case ContentSource.tiktok:
        return AppColors.tiktok;
      case ContentSource.youtube:
        return AppColors.youtube;
      case ContentSource.twitter:
        return AppColors.twitter;
      case ContentSource.reddit:
        return AppColors.reddit;
      case ContentSource.linkedin:
        return AppColors.linkedin;
      case ContentSource.facebook:
        return AppColors.facebook;
      case ContentSource.pinterest:
        return const Color(0xFFE60023);
      case ContentSource.article:
        return AppColors.info;
      case ContentSource.podcast:
        return AppColors.secondary;
      case ContentSource.other:
        return AppColors.textSecondary;
    }
  }

  /// Convert to database string
  String toJson() => name;

  /// Parse from database string
  static ContentSource fromJson(String value) {
    return ContentSource.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ContentSource.other,
    );
  }
}
