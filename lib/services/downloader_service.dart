import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_downloader/flutter_downloader.dart';
import 'notification_service.dart';

class DownloaderService {
  static final ReceivePort _port = ReceivePort();

  static void initialize() {
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = DownloadTaskStatus.fromInt(data[1]);
      int progress = data[2];

      if (status == DownloadTaskStatus.complete) {
        _handleDownloadComplete(id);
      }
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  static Future<void> _handleDownloadComplete(String taskId) async {
    final tasks = await FlutterDownloader.loadTasksWithRawQuery(
        query: "SELECT * FROM task WHERE task_id = '$taskId'");
    if (tasks == null || tasks.isEmpty) return;

    final task = tasks.first;
    final filePath = p.join(task.savedDir, task.filename);

    try {
      // Save to Gallery
      final isVideo = task.filename?.toLowerCase().endsWith('.mp4') ?? false;
      if (isVideo) {
        await Gal.putVideo(filePath);
      } else {
        await Gal.putImage(filePath);
      }

      // Show notification
      await NotificationService.showDownloadCompleteNotification(
        fileName: task.filename ?? 'Media',
      );

      // Clean up temp file
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error handling download completion: $e');
    }
  }

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
      if (!await checkInternet()) {
        onError('No internet connection.');
        return;
      }

      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        final granted = await Gal.requestAccess(toAlbum: true);
        if (!granted) {
          onError('Gallery access denied.');
          return;
        }
      }

      final tempDir = await getTemporaryDirectory();

      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: tempDir.path,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: false,
        saveInPublicStorage: false,
      );

      if (taskId != null) {
        onSuccess('Download started in background...');
      } else {
        onError('Could not start download.');
      }
    } catch (e) {
      onError('Error: ${e.toString()}');
    }
  }
}
