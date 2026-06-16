import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;

class DownloaderService {
  static final Dio _dio = Dio();

  static Future<void> downloadFile({
    required String url,
    required String fileName,
    Function(int, int)? onProgress,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    try {
      // Request permissions
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          // Check for Android 13+ permissions
          final photos = await Permission.photos.request();
          final videos = await Permission.videos.request();
          if (!photos.isGranted && !videos.isGranted) {
            onError('Storage permission denied');
            return;
          }
        }
      }

      Directory? directory;
      if (Platform.isAndroid) {
        // Try standard Download folder first
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          // Fallback to app-specific external storage
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        onError('Could not find download directory');
        return;
      }

      final savePath = p.join(directory.path, fileName);

      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onProgress,
      );

      onSuccess(savePath);
    } catch (e) {
      onError('Download failed: $e');
    }
  }
}
