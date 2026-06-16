import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/media_info.dart';

class MediaExtractorService {
  static Future<List<MediaInfo>> extract(String url) async {
    String normalizedUrl = url.trim();

    if (normalizedUrl.isEmpty) {
      throw 'Please enter a URL first.';
    }

    if (!normalizedUrl.startsWith('http')) {
      throw 'Invalid URL. Please enter a valid link starting with http:// or https://';
    }

    if (normalizedUrl.contains('kingsch.at/p/')) {
      final postId = normalizedUrl.split('/').last;
      normalizedUrl = 'https://kingschat.online/post/$postId';
    }

    try {
      if (normalizedUrl.contains('kingschat.online') || normalizedUrl.contains('kingsch.at')) {
        return await _extractKingsChat(normalizedUrl);
      } else if (normalizedUrl.contains('ceflix.org')) {
        final result = await _extractCeFlix(normalizedUrl);
        return result != null ? [result] : [];
      } else if (normalizedUrl.contains('facebook.com') || normalizedUrl.contains('fb.watch')) {
        return await _extractFacebook(normalizedUrl);
      }

      final genericResult = await _extractGeneric(normalizedUrl);
      return genericResult != null ? [genericResult] : [];
    } catch (e) {
      debugPrint('Extraction Error: $e');
      return [];
    }
  }

  static Future<List<MediaInfo>> _extractFacebook(String url) async {
    try {
      String targetUrl = url;
      if (url.contains('/share/')) {
        targetUrl = url.replaceFirst('web.facebook.com', 'm.facebook.com')
                       .replaceFirst('www.facebook.com', 'm.facebook.com');
      }

      final response = await http.get(
        Uri.parse(targetUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return [];

      final html = response.body;
      final cleanHtml = html.replaceAll('\\/', '/');

      // 1. Try to find HD/SD Video URL
      String? videoUrl = RegExp(r'browser_native_hd_url":"([^"]+)"').firstMatch(cleanHtml)?.group(1) ??
                         RegExp(r'hd_src":"([^"]+)"').firstMatch(cleanHtml)?.group(1) ??
                         RegExp(r'browser_native_sd_url":"([^"]+)"').firstMatch(cleanHtml)?.group(1) ??
                         RegExp(r'sd_src":"([^"]+)"').firstMatch(cleanHtml)?.group(1) ??
                         RegExp(r'video_url":"([^"]+)"').firstMatch(cleanHtml)?.group(1);

      // 2. Try to find Image
      String? imageUrl = RegExp(r'scaled_image_url":"([^"]+)"').firstMatch(cleanHtml)?.group(1) ??
                         RegExp(r'preferred_thumbnail":{"image":{"uri":"([^"]+)"').firstMatch(cleanHtml)?.group(1) ??
                         RegExp(r'thumbnail_url":"([^"]+)"').firstMatch(cleanHtml)?.group(1) ??
                         RegExp(r'property="og:image" content="([^"]+)"').firstMatch(html)?.group(1);

      String title = RegExp(r'property="og:title" content="([^"]+)"').firstMatch(html)?.group(1) ??
                     RegExp(r'<title>(.*?)<\/title>').firstMatch(html)?.group(1) ??
                     'Facebook Post';

      final normalizedVideo = _normalizeMediaUrl(videoUrl, url);
      final normalizedImage = _normalizeMediaUrl(imageUrl, url);

      List<MediaInfo> results = [];
      if (normalizedVideo != null) {
        results.add(MediaInfo(
          title: title,
          url: normalizedVideo,
          thumbnailUrl: normalizedImage,
          type: MediaType.video,
          platform: 'Facebook',
        ));
      } else if (normalizedImage != null) {
        results.add(MediaInfo(
          title: title,
          url: normalizedImage,
          thumbnailUrl: normalizedImage,
          type: MediaType.image,
          platform: 'Facebook',
        ));
      }
      return results;
    } catch (e) {
      debugPrint('Facebook Extraction Error: $e');
    }
    return [];
  }

  static Future<List<MediaInfo>> _extractKingsChat(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        },
      );
      if (response.statusCode != 200) return [];

      final html = response.body;
      final searchHtml = html
          .replaceAll('\\/', '/')
          .replaceAll('\\u002F', '/')
          .replaceAll('\\u003D', '=')
          .replaceAll('\\u0026', '&');

      // Find Title
      final titleMatch = RegExp(r'textBody[:=][\\"]+(.*?)[\\"]+').firstMatch(html);
      String title = titleMatch?.group(1)?.replaceAll('\\n', ' ').replaceAll('\\', '') ?? 'KingsChat Post';
      if (title == 'KingsChat Post') {
        final ogTitleMatch = RegExp(r'property="og:title" content="(.*?)"').firstMatch(html);
        title = ogTitleMatch?.group(1) ?? title;
      }

      List<MediaInfo> results = [];
      final cdnRegex = RegExp(r'https?://(?:cdn[0-9]*\.kingschat\.online|d1z1smzgvvydhp\.cloudfront\.net)/uploads/media/[^\s"<>\\]+');
      final cdnMatches = cdnRegex.allMatches(searchHtml);

      Set<String> seenUrls = {};

      for (final match in cdnMatches) {
        final found = match.group(0)!;
        final normalized = _normalizeMediaUrl(found, url);
        if (normalized == null || seenUrls.contains(normalized)) continue;

        // Skip obvious small thumbnails or avatars
        if (normalized.contains('/160/') || normalized.contains('/500/')) continue;

        MediaType type = MediaType.image;
        if (normalized.contains('.mp4') || normalized.contains('.temp') || normalized.contains('.m3u8')) {
          type = MediaType.video;
        } else if (!normalized.contains('.jpg') && !normalized.contains('.png') && !normalized.contains('.jpeg') && !normalized.contains('.webp')) {
           // If it doesn't have an image extension, but it's from the media path, it might be a video without extension
           if (normalized.contains('/media/')) {
             // KingsChat often uses /media/ for both, check if it contains 'managed' or other video markers
             if (normalized.contains('managed')) type = MediaType.video;
           }
        }

        seenUrls.add(normalized);
        results.add(MediaInfo(
          title: title,
          url: normalized,
          thumbnailUrl: type == MediaType.video ? null : normalized,
          type: type,
          platform: 'KingsChat',
        ));
      }

      // If we found nothing with CDN regex, fallback to OG
      if (results.isEmpty) {
        final ogImageMatch = RegExp(r'property="og:image" content="(.*?)"').firstMatch(searchHtml);
        final normalizedOg = _normalizeMediaUrl(ogImageMatch?.group(1), url);
        if (normalizedOg != null) {
          results.add(MediaInfo(
            title: title,
            url: normalizedOg,
            thumbnailUrl: normalizedOg,
            type: MediaType.image,
            platform: 'KingsChat',
          ));
        }
      }

      return results;
    } catch (e) {
      debugPrint('KingsChat Extraction Error: $e');
    }
    return [];
  }

  static Future<MediaInfo?> _extractCeFlix(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        },
      );
      if (response.statusCode != 200) return null;

      final html = response.body;
      final titleMatch = RegExp(r'<title>(.*?)<\/title>').firstMatch(html);
      final title = titleMatch?.group(1) ?? 'CeFlix Video';

      String? videoUrl = RegExp(r'property="og:video" content="(.*?)"').firstMatch(html)?.group(1) ??
                         RegExp(r'<source[^>]*src="([^"]+)"').firstMatch(html)?.group(1) ??
                         RegExp(r'file\s*:\s*"([^"]+\.(?:mp4|m3u8)[^"]*)"').firstMatch(html)?.group(1);

      final normalizedVideoUrl = _normalizeMediaUrl(videoUrl, url);
      if (normalizedVideoUrl != null) {
        return MediaInfo(
          title: title,
          url: normalizedVideoUrl,
          thumbnailUrl: null,
          type: MediaType.video,
          platform: 'CeFlix',
        );
      }
    } catch (_) {}
    return null;
  }

  static Future<MediaInfo?> _extractGeneric(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final html = response.body;
      String? videoUrl = RegExp(r'property="og:video(?::secure_url)?"\s+content="([^"]+)"').firstMatch(html)?.group(1);
      String? imageUrl = RegExp(r'property="og:image(?::secure_url)?"\s+content="([^"]+)"').firstMatch(html)?.group(1);

      final normalizedVideo = _normalizeMediaUrl(videoUrl, url);
      final normalizedImage = _normalizeMediaUrl(imageUrl, url);

      if (normalizedVideo != null) {
        return MediaInfo(
          title: 'Media Content',
          url: normalizedVideo,
          thumbnailUrl: normalizedImage,
          type: MediaType.video,
          platform: 'Web',
        );
      } else if (normalizedImage != null) {
        return MediaInfo(
          title: 'Media Content',
          url: normalizedImage,
          thumbnailUrl: normalizedImage,
          type: MediaType.image,
          platform: 'Web',
        );
      }
    } catch (_) {}
    return null;
  }

  static String? _normalizeMediaUrl(String? url, String baseUrl) {
    if (url == null || url.trim().isEmpty) return null;
    String normalized = url.trim();
    if (normalized.startsWith('//')) normalized = 'https:$normalized';
    if (normalized.startsWith('/')) {
      final uri = Uri.parse(baseUrl);
      normalized = '${uri.scheme}://${uri.host}$normalized';
    }
    return normalized;
  }
}
