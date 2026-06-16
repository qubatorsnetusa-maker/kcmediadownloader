enum MediaType { video, image, unknown }

class MediaInfo {
  final String title;
  final String? url;
  final String? thumbnailUrl;
  final MediaType type;
  final String platform; // "KingsChat" or "CeFlix"

  MediaInfo({
    required this.title,
    this.url,
    this.thumbnailUrl,
    required this.type,
    required this.platform,
  });
}
