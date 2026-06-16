import 'package:http/http.dart' as http;
import '../models/media_info.dart';

class MediaExtractorService {
  static Future<MediaInfo?> extract(String url) async {
    // 1. Normalize the URL
    String normalizedUrl = url.trim();

    // Handle short links
    if (normalizedUrl.contains('kingsch.at/p/')) {
      final postId = normalizedUrl.split('/').last;
      normalizedUrl = 'https://kingschat.online/post/$postId';
    }

    if (normalizedUrl.contains('kingschat.online') || normalizedUrl.contains('kingsch.at')) {
      return await _extractKingsChat(normalizedUrl);
    } else if (normalizedUrl.contains('ceflix.org')) {
      return await _extractCeFlix(normalizedUrl);
    } else if (normalizedUrl.contains('facebook.com') || normalizedUrl.contains('fb.watch')) {
      return await _extractFacebook(normalizedUrl);
    }

    // Fallback to Generic Extractor for other platforms (Pinterest, LinkedIn, etc.)
    return await _extractGeneric(normalizedUrl);
  }

  static Future<MediaInfo?> _extractFacebook(String url) async {
    try {
      // 1. Handle Facebook Share Links - they often redirect
      String targetUrl = url;
      if (url.contains('/share/')) {
        // Force to mobile to potentially avoid complex desktop-only JS rendering
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

      if (response.statusCode != 200) return null;

      final html = response.body;
      final cleanHtml = html.replaceAll('\\/', '/');

      // 1. Try to find HD/SD Video URL in JSON/Script
      String? videoUrl = RegExp(r'browser_native_hd_url":"([^"]+)"').firstMatch(cleanHtml)?.group(1) ??
                         RegExp(r'hd_src":"([^"]+)"').firstMatch(cleanHtml)?.group(1) ??
                         RegExp(r'browser_native_sd_url":"([^"]+)"').firstMatch(cleanHtml)?.group(1) ??
                         RegExp(r'sd_src":"([^"]+)"').firstMatch(cleanHtml)?.group(1) ??
                         RegExp(r'video_url":"([^"]+)"').firstMatch(cleanHtml)?.group(1);

      // 2. Look for any mp4 link in the page as fallback
      videoUrl ??= RegExp(r'https?://[^\s"\\\]+?\.mp4[^\s"\\\]*').firstMatch(cleanHtml)?.group(0);

      // 3. Find Image / Thumbnail
      // Try specific FB JSON keys for images first, then OG tags, then broad CDN scan
      String? imageUrl = RegExp(r'scaled_image_url":"([^"]+)"').firstMatch(cleanHtml)?.group(1) ??
                         RegExp(r'preferred_thumbnail":{"image":{"uri":"([^"]+)"').firstMatch(cleanHtml)?.group(1) ??
                         RegExp(r'thumbnail_url":"([^"]+)"').firstMatch(cleanHtml)?.group(1) ??
                         RegExp(r'property="og:image" content="([^"]+)"').firstMatch(html)?.group(1) ??
                         // Broad search for high-res scontent images
                         RegExp(r'https?://[^\s"\\\]+?scontent[^\s"\\\]+?\.jpg[^\s"\\\]*').firstMatch(cleanHtml)?.group(0);

      // 4. Find Title
      String title = RegExp(r'property="og:title" content="([^"]+)"').firstMatch(html)?.group(1) ??
                     RegExp(r'<title>(.*?)<\/title>').firstMatch(html)?.group(1) ??
                     'Facebook Post';

      final normalizedVideo = _normalizeMediaUrl(videoUrl, url);
      final normalizedImage = _normalizeMediaUrl(imageUrl, url);

      // If we found a video, use it
      if (normalizedVideo != null) {
        return MediaInfo(
          title: title,
          url: normalizedVideo,
          thumbnailUrl: normalizedImage,
          type: MediaType.video,
          platform: 'Facebook',
        );
      }

      // If no video, but we found an image, use the image
      if (normalizedImage != null) {
        return MediaInfo(
          title: title,
          url: normalizedImage,
          thumbnailUrl: normalizedImage,
          type: MediaType.image,
          platform: 'Facebook',
        );
      }
    } catch (e) {
      print('Facebook Extraction Error: $e');
    }

    // Final fallback: try generic
    return await _extractGeneric(url);
  }

  static Future<MediaInfo?> _extractGeneric(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final html = response.body;

      // 1. Try to find Video (OpenGraph, Twitter Cards, etc.)
      String? videoUrl =
          RegExp(r'property="og:video(?::secure_url)?"\s+content="([^"]+)"').firstMatch(html)?.group(1) ??
          RegExp(r'name="twitter:player:stream"\s+content="([^"]+)"').firstMatch(html)?.group(1);

      // 2. Try to find Image
      String? imageUrl =
          RegExp(r'property="og:image(?::secure_url)?"\s+content="([^"]+)"').firstMatch(html)?.group(1) ??
          RegExp(r'name="twitter:image"\s+content="([^"]+)"').firstMatch(html)?.group(1);

      // 3. Try to find Title
      String title =
          RegExp(r'property="og:title"\s+content="([^"]+)"').firstMatch(html)?.group(1) ??
          RegExp(r'<title>(.*?)<\/title>').firstMatch(html)?.group(1) ??
          'Media Content';

      final normalizedVideo = _normalizeMediaUrl(videoUrl, url);
      final normalizedImage = _normalizeMediaUrl(imageUrl, url);

      if (normalizedVideo != null) {
        return MediaInfo(
          title: title,
          url: normalizedVideo,
          thumbnailUrl: normalizedImage,
          type: MediaType.video,
          platform: _getPlatformName(url),
        );
      }

      if (normalizedImage != null) {
        return MediaInfo(
          title: title,
          url: normalizedImage,
          thumbnailUrl: normalizedImage,
          type: MediaType.image,
          platform: _getPlatformName(url),
        );
      }
    } catch (e) {
      print('Generic Extraction Error: $e');
    }
    return null;
  }

  static String _getPlatformName(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host.toLowerCase();
      if (host.contains('facebook.com')) return 'Facebook';
      if (host.contains('pinterest.com')) return 'Pinterest';
      if (host.contains('linkedin.com')) return 'LinkedIn';
      if (host.contains('instagram.com')) return 'Instagram';
      if (host.contains('x.com') || host.contains('twitter.com')) return 'X / Twitter';
      if (host.contains('youtube.com') || host.contains('youtu.be')) return 'YouTube';

      // Return capitalized domain name as fallback
      final parts = host.split('.');
      if (parts.length >= 2) {
        final domain = parts[parts.length - 2];
        return domain[0].toUpperCase() + domain.substring(1);
      }
      return 'Web';
    } catch (_) {
      return 'Web';
    }
  }

  static String? _normalizeMediaUrl(String? url, String baseUrl) {
    if (url == null || url.trim().isEmpty) return null;
    String normalized = url.trim();

    // Handle protocol-relative URLs
    if (normalized.startsWith('//')) {
      normalized = 'https:$normalized';
    }

    // Handle relative URLs
    if (normalized.startsWith('/')) {
      final uri = Uri.parse(baseUrl);
      normalized = '${uri.scheme}://${uri.host}$normalized';
    }

    // Basic validation to ensure it has a host
    try {
      final uri = Uri.parse(normalized);
      if (!uri.hasAuthority || uri.host.isEmpty) {
        return null;
      }
    } catch (e) {
      return null;
    }

    return normalized;
  }

  static Future<MediaInfo?> _extractKingsChat(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        },
      );
      if (response.statusCode != 200) return null;

      final html = response.body;

      // 1. Aggressive Video Search
      String? videoUrl;

      // Clean the HTML for searching to handle escaped slashes and unicode
      final searchHtml = html
          .replaceAll('\\/', '/')
          .replaceAll('\\u002F', '/')
          .replaceAll('\\u003D', '=')
          .replaceAll('\\u0026', '&');

      // Broadest search for any KingsChat CDN link that isn't a known small thumbnail
      // Updated regex to be more inclusive of possible extensions
      final cdnRegex = RegExp(r'https?://(?:cdn[0-9]*\.kingschat\.online|d1z1smzgvvydhp\.cloudfront\.net)/uploads/media/[^\s"<>\\\]]+');
      final cdnMatches = cdnRegex.allMatches(searchHtml);

      for (final match in cdnMatches) {
        final found = match.group(0)!;

        // Skip common webp thumbnails if we are looking for the main video/image
        if (found.contains('.webp') && (found.contains('/160/') || found.contains('/500/'))) {
          continue;
        }

        // If we find a .temp, .mp4, or .m3u8, that's likely our video!
        if (found.contains('.temp') || found.contains('.mp4') || found.contains('.m3u8') || found.contains('managed')) {
          videoUrl = found;
          break;
        }

        // If we haven't found a video yet, this might be our primary media
        if (videoUrl == null) {
          videoUrl = found;
        }
      }

      // Fallback: If no direct URL found, try to find it in JSON-like structures or script tags
      if (videoUrl == null) {
        final jsonKeysRegex = RegExp(r'(?:videoUrl|mediaUrl|downloadUrl|fileUrl|sourceUrl|hlsUrl)[:=][\s\\"]+([^\s\\"]+?(\.temp|\.mp4|\.m3u8)[^\s\\"]*)');
        final keyMatch = jsonKeysRegex.firstMatch(searchHtml);
        if (keyMatch != null) {
          videoUrl = keyMatch.group(1);
        }
      }

      // Fallback B: <video src="..."> or <source src="...">
      if (videoUrl == null) {
        final videoTagMatch = RegExp(r'<(?:video|source)[^>]*src="([^"]+)"').firstMatch(searchHtml);
        if (videoTagMatch != null) {
          videoUrl = videoTagMatch.group(1);
        }
      }

      // Fallback C: og:video
      if (videoUrl == null) {
        final ogVideoMatch = RegExp(r'property="og:video" content="([^"]+)"').firstMatch(searchHtml);
        if (ogVideoMatch != null) {
          videoUrl = ogVideoMatch.group(1);
        }
      }

      final normalizedVideoUrl = _normalizeMediaUrl(videoUrl, url);

      if (normalizedVideoUrl != null) {
        // Find title
        final titleMatch = RegExp(r'textBody[:=][\\"]+(.*?)[\\"]+').firstMatch(html);
        String title = titleMatch?.group(1)?.replaceAll('\\n', ' ').replaceAll('\\', '') ?? 'KingsChat Video';
        if (title == 'KingsChat Video') {
          final ogTitleMatch = RegExp(r'property="og:title" content="(.*?)"').firstMatch(html);
          title = ogTitleMatch?.group(1) ?? title;
        }

        // Find thumbnail
        final thumbMatch = RegExp(r'imageUrl[:=][\\"]+(.*?)[\\"]+').firstMatch(html);
        String? thumbUrl = thumbMatch?.group(1)?.replaceAll('\\u002F', '/').replaceAll('\\', '');

        if (thumbUrl == null) {
          final posterMatch = RegExp(r'<video[^>]*poster="([^"]+)"').firstMatch(html);
          thumbUrl = posterMatch?.group(1);
        }

        final normalizedThumbUrl = _normalizeMediaUrl(thumbUrl ?? '', url);

        return MediaInfo(
          title: title,
          url: normalizedVideoUrl,
          thumbnailUrl: normalizedThumbUrl,
          type: MediaType.video,
          platform: 'KingsChat',
        );
      }

      // 2. Fallback to Image extraction ONLY if we are sure there is no video
      // If we see 'video' or 'PostVideo' in the HTML, we should be very reluctant to fallback to images
      final looksLikeVideo = searchHtml.contains('video') || searchHtml.contains('PostVideo') || searchHtml.contains('player');

      if (videoUrl == null && !looksLikeVideo) {
        final imageMatch = RegExp(r'imageUrl[:=][\\"]+(.*?)[\\"]+').firstMatch(html);
        if (imageMatch != null) {
          String imageUrl = imageMatch.group(1)!;
          imageUrl = imageUrl.replaceAll('\\u002F', '/').replaceAll('\\', '');

          final normalizedImageUrl = _normalizeMediaUrl(imageUrl, url);

          if (normalizedImageUrl != null) {
            final titleMatch = RegExp(r'textBody[:=][\\"]+(.*?)[\\"]+').firstMatch(html);
            String title = titleMatch?.group(1)?.replaceAll('\\n', ' ').replaceAll('\\', '') ?? 'KingsChat Image';

            return MediaInfo(
              title: title,
              url: normalizedImageUrl,
              thumbnailUrl: normalizedImageUrl,
              type: MediaType.image,
              platform: 'KingsChat',
            );
          }
        }
      }

      // 3. Last fallback: OpenGraph tags (Only if we haven't found anything yet)
      if (videoUrl == null) {
        final ogImageMatch = RegExp(r'property="og:image" content="(.*?)"').firstMatch(html);
        final ogTitleMatch = RegExp(r'property="og:title" content="(.*?)"').firstMatch(html);

        if (ogImageMatch != null) {
          final imageUrl = ogImageMatch.group(1);
          final normalizedImageUrl = _normalizeMediaUrl(imageUrl, url);

          if (normalizedImageUrl != null) {
            // If it's a video post but we only found an OG image, it might be the only link available
            // but we should mark it correctly.
            return MediaInfo(
              title: ogTitleMatch?.group(1) ?? 'KingsChat Post',
              url: normalizedImageUrl,
              thumbnailUrl: normalizedImageUrl,
              type: looksLikeVideo ? MediaType.video : MediaType.image,
              platform: 'KingsChat',
            );
          }
        }
      }

    } catch (e) {
      // ignore: avoid_print
      print('KingsChat Extraction Error: $e');
    }
    return null;
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

      final ogImageMatch = RegExp(r'property="og:image" content="(.*?)"').firstMatch(html);
      final thumbnailUrl = ogImageMatch?.group(1);
      final normalizedThumbUrl = _normalizeMediaUrl(thumbnailUrl, url);

      // Try to find a video source in common CeFlix patterns
      String? videoUrl;

      // Pattern 0: og:video
      final ogVideoMatch = RegExp(r'property="og:video" content="(.*?)"').firstMatch(html);
      if (ogVideoMatch != null) {
        videoUrl = ogVideoMatch.group(1);
      }

      // Pattern 1: <source src="...">
      if (videoUrl == null) {
        final sourceMatch = RegExp(r'<source[^>]*src="([^"]+)"').firstMatch(html);
        if (sourceMatch != null) {
          videoUrl = sourceMatch.group(1);
        }
      }

      // Pattern 1.5: iframe src (for embedded players)
      if (videoUrl == null) {
        final iframeMatch = RegExp(r'<iframe[^>]*src="([^"]+)"').firstMatch(html);
        if (iframeMatch != null) {
          final iframeUrl = iframeMatch.group(1);
          if (iframeUrl != null && (iframeUrl.contains('ceflix.org') || iframeUrl.contains('player'))) {
             // We might need to recursively fetch this, but for now just try it
             videoUrl = iframeUrl;
          }
        }
      }

      // Pattern 2: file: "..." in script
      if (videoUrl == null) {
        final fileMatch = RegExp(r'file\s*:\s*"([^"]+\.(?:mp4|m3u8)[^"]*)"').firstMatch(html);
        if (fileMatch != null) {
          videoUrl = fileMatch.group(1);
        }
      }

      final normalizedVideoUrl = _normalizeMediaUrl(videoUrl, url);

      return MediaInfo(
        title: title,
        url: normalizedVideoUrl,
        thumbnailUrl: normalizedThumbUrl,
        type: MediaType.video,
        platform: 'CeFlix',
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error extracting CeFlix: $e');
    }
    return null;
  }
}
