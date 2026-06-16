import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:path/path.dart' as p;

class DownloaderService {
  static final Dio _dio = Dio();

  static Future<void> downloadFile({
    required String url,
    required String fileName,
    required bool isVideo,
    Function(int, int)? onProgress,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    try {
      // 1. Check/Request Gallery Access
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        final granted = await Gal.requestAccess(toAlbum: true);
        if (!granted) {
          onError('Gallery access denied. Please enable it in settings.');
          return;
        }
      }

      // 2. Get temp directory for downloading
      final tempDir = await getTemporaryDirectory();
      final tempPath = p.join(tempDir.path, fileName);

      // 3. Download the file to temp location
      await _dio.download(
        url,
        tempPath,
        onReceiveProgress: onProgress,
      );

      // 4. Save to Gallery
      if (isVideo) {
        await Gal.putVideo(tempPath);
      } else {
        await Gal.putImage(tempPath);
      }

      // 5. Clean up temp file (optional, but good practice)
      try {
        final file = File(tempPath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Ignore deletion errors
      }

      onSuccess('Saved to Gallery');
    } catch (e) {
      if (e is GalException) {
        onError('Gallery Error: ${e.type.name}');
      } else {
        onError('Download failed: $e');
      }
    }
  }
}
