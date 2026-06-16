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
  static final List<Function(String, DownloadTaskStatus, int)> _listeners = [];

  static void initialize() {
    // Only register once
    if (IsolateNameServer.lookupPortByName('downloader_send_port') != null) {
      IsolateNameServer.removePortNameMapping('downloader_send_port');
    }

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');

    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = DownloadTaskStatus.fromInt(data[1]);
      int progress = data[2];

      debugPrint('Downloader update: ID=$id, Status=$status, Progress=$progress');

      if (status == DownloadTaskStatus.complete) {
        _handleDownloadComplete(id);
      }

      for (var listener in _listeners) {
        listener(id, status, progress);
      }
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  static void addListener(Function(String, DownloadTaskStatus, int) listener) {
    _listeners.add(listener);
  }

  static void removeListener(Function(String, DownloadTaskStatus, int) listener) {
    _listeners.remove(listener);
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  static Future<void> _handleDownloadComplete(String taskId) async {
    try {
      final tasks = await FlutterDownloader.loadTasksWithRawQuery(
          query: "SELECT * FROM task WHERE task_id = '$taskId'");

      if (tasks == null || tasks.isEmpty) {
        debugPrint('Error: Could not find task $taskId in database');
        return;
      }

      final task = tasks.first;
      final fileName = task.filename ?? 'downloaded_file';
      final filePath = p.join(task.savedDir, fileName);
      final file = File(filePath);

      debugPrint('Attempting to save to gallery: $filePath');

      if (!await file.exists()) {
        debugPrint('Error: Downloaded file does not exist at $filePath');
        return;
      }

      // Check if it's an image or video based on extension
      final lowerFileName = fileName.toLowerCase();
      final isVideo = lowerFileName.endsWith('.mp4') ||
                      lowerFileName.endsWith('.mov') ||
                      lowerFileName.endsWith('.avi');

      try {
        if (isVideo) {
          debugPrint('Saving as video to gallery...');
          await Gal.putVideo(filePath);
        } else {
          debugPrint('Saving as image to gallery...');
          await Gal.putImage(filePath);
        }
        debugPrint('Successfully saved to gallery!');

        // Show notification
        await NotificationService.showDownloadCompleteNotification(
          fileName: fileName,
        );

        // Clean up temp file AFTER successful gallery save
        if (await file.exists()) {
          await file.delete();
          debugPrint('Deleted temporary file: $filePath');
        }
      } on GalException catch (ge) {
        debugPrint('GalException saving to gallery: ${ge.type}');
      } catch (e) {
        debugPrint('General error saving to gallery: $e');
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

  static Future<String?> downloadFile({
    required String url,
    required String fileName,
    required bool isVideo,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    try {
      if (!await checkInternet()) {
        onError('No internet connection.');
        return null;
      }

      // Ensure we have access before starting
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        final granted = await Gal.requestAccess(toAlbum: true);
        if (!granted) {
          onError('Gallery access denied.');
          return null;
        }
      }

      final tempDir = await getTemporaryDirectory();

      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: tempDir.path,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: false,
        saveInPublicStorage: false, // Save to app-private cache first
      );

      if (taskId != null) {
        onSuccess('Download started...');
        return taskId;
      } else {
        onError('Could not start download.');
        return null;
      }
    } catch (e) {
      onError('Error: ${e.toString()}');
      return null;
    }
  }
}
