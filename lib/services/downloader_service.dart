import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:path/path.dart' as p;

class DownloaderService {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 60),
    followRedirects: true,
  ));

  static Future<bool> checkInternet() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    }
    return true;
  }

  static Future<void> downloadFile({
    required String url,
    required String fileName,
    required bool isVideo,
    Function(int, int)? onProgress,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    try {
      // 0. Check Internet
      if (!await checkInternet()) {
        onError('No internet connection. Please check your network settings.');
        return;
      }

      // 1. Check Gallery Access
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        final granted = await Gal.requestAccess(toAlbum: true);
        if (!granted) {
          onError('Gallery access denied. Please enable it in Settings.');
          return;
        }
      }

      // 2. Get temp directory for downloading
      final tempDir = await getTemporaryDirectory();
      final tempPath = p.join(tempDir.path, fileName);

      // 3. Download the file
      await _dio.download(
        url,
        tempPath,
        onReceiveProgress: (count, total) {
          if (onProgress != null && total > 0) {
            onProgress(count, total);
          }
        },
      );

      // Verify file exists and has size
      final file = File(tempPath);
      if (!await file.exists() || await file.length() == 0) {
        throw Exception('Downloaded file is empty or missing.');
      }

      // 4. Save to Gallery
      if (isVideo) {
        await Gal.putVideo(tempPath);
      } else {
        await Gal.putImage(tempPath);
      }

      // 5. Clean up
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}

      onSuccess('Saved to Gallery');
    } catch (e, stack) {
      debugPrint('Download Error: $e');
      debugPrint(stack.toString());

      if (e is GalException) {
        final type = e.type.name;
        String message = 'Gallery Error: $type';
        if (type == 'accessDenied') message = 'Please grant Gallery permissions in your phone settings.';
        if (type == 'notSupported') message = 'This file format is not supported by your gallery.';
        onError(message);
      } else if (e is DioException) {
        onError('Network Error: ${e.message ?? 'Unknown connection issue'}');
      } else {
        onError('Error: ${e.toString()}');
      }
    }
  }
}
