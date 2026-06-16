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
  static final List<Function(String taskId, String url, DownloadTaskStatus status, int progress)> _listeners = [];

  static void initialize() {
    if (IsolateNameServer.lookupPortByName('downloader_send_port') != null) {
      IsolateNameServer.removePortNameMapping('downloader_send_port');
    }

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');

    _port.listen((dynamic data) async {
      String id = data[0];
      DownloadTaskStatus status = DownloadTaskStatus.fromInt(data[1]);
      int progress = data[2];

      debugPrint('Downloader update: ID=$id, Status=$status, Progress=$progress');

      // Get the URL for this task from the DB to help the UI identify it
      String url = '';
      try {
        final tasks = await FlutterDownloader.loadTasksWithRawQuery(
            query: "SELECT * FROM task WHERE task_id = '$id'");
        if (tasks != null && tasks.isNotEmpty) {
          url = tasks.first.url;
        }
      } catch (e) {
        debugPrint('Error querying task URL: $e');
      }

      if (status == DownloadTaskStatus.complete) {
        await _handleDownloadComplete(id);
      }

      for (var listener in List.from(_listeners)) {
        listener(id, url, status, progress);
      }
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  static void addListener(Function(String, String, DownloadTaskStatus, int) listener) {
    _listeners.add(listener);
  }

  static void removeListener(Function(String, String, DownloadTaskStatus, int) listener) {
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

      final fileSize = await file.length();
      debugPrint('Downloaded file size: $fileSize bytes');

      if (fileSize == 0) {
        debugPrint('Error: Downloaded file is empty (0 bytes). Link might be broken or expired.');
        return;
      }

      final lowerFileName = fileName.toLowerCase();
      final isVideo = lowerFileName.endsWith('.mp4') ||
                      lowerFileName.endsWith('.mov') ||
                      lowerFileName.endsWith('.avi') ||
                      task.url.toLowerCase().contains('.mp4');

      try {
        if (isVideo) {
          debugPrint('Saving as video to gallery...');
          await Gal.putVideo(filePath, album: 'Nexus Downloader');
        } else {
          debugPrint('Saving as image to gallery...');
          await Gal.putImage(filePath, album: 'Nexus Downloader');
        }
        debugPrint('Successfully saved to gallery!');

        await NotificationService.showDownloadCompleteNotification(
          fileName: fileName,
        );

        // Clean up temp file
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

      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        final granted = await Gal.requestAccess(toAlbum: true);
        if (!granted) {
          onError('Gallery access denied.');
          return null;
        }
      }

      final tempDir = await getApplicationDocumentsDirectory(); // More stable than temp on some devices
      final downloadPath = p.join(tempDir.path, 'downloads');
      final dir = Directory(downloadPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Clear previous tasks with same URL to avoid conflicts
      try {
        final existingTasks = await FlutterDownloader.loadTasksWithRawQuery(
            query: "SELECT * FROM task WHERE url = '$url'");
        if (existingTasks != null) {
          for (var task in existingTasks) {
            await FlutterDownloader.remove(taskId: task.taskId, shouldDeleteContent: true);
          }
        }
      } catch (_) {}

      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: downloadPath,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: false,
        saveInPublicStorage: false,
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
