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
    debugPrint('Initializing DownloaderService...');

    if (IsolateNameServer.lookupPortByName('downloader_send_port') != null) {
      debugPrint('Removing old port mapping...');
      IsolateNameServer.removePortNameMapping('downloader_send_port');
    }

    final bool success = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');

    debugPrint('Port registration success: $success');

    _port.listen((dynamic data) async {
      final String id = data[0];
      final DownloadTaskStatus status = DownloadTaskStatus.fromInt(data[1]);
      final int progress = data[2];

      debugPrint('Main Isolate received update: ID=$id, Status=$status, Progress=$progress');

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
        debugPrint('Download complete event for $id. Triggering gallery save...');
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
    debugPrint('Listener added. Total listeners: ${_listeners.length}');
  }

  static void removeListener(Function(String, String, DownloadTaskStatus, int) listener) {
    _listeners.remove(listener);
    debugPrint('Listener removed. Total listeners: ${_listeners.length}');
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    debugPrint('Background Isolate callback: ID=$id, Status=$status, Progress=$progress');
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');

    if (send != null) {
      send.send([id, status, progress]);
    } else {
      debugPrint('Error: Could not find SendPort "downloader_send_port"');
    }
  }

  static Future<void> _handleDownloadComplete(String taskId) async {
    try {
      final tasks = await FlutterDownloader.loadTasksWithRawQuery(
          query: "SELECT * FROM task WHERE task_id = '$taskId'");

      if (tasks == null || tasks.isEmpty) {
        debugPrint('Error: Task $taskId not found in DB during completion handling');
        return;
      }

      final task = tasks.first;
      final fileName = task.filename ?? 'downloaded_file';
      final filePath = p.join(task.savedDir, fileName);
      final file = File(filePath);

      debugPrint('Validating file for gallery save: $filePath');

      if (!await file.exists()) {
        debugPrint('Error: File NOT found on disk: $filePath');
        return;
      }

      final fileSize = await file.length();
      debugPrint('File size: $fileSize bytes');

      if (fileSize == 0) {
        debugPrint('Error: File is empty. Gallery save aborted.');
        return;
      }

      final lowerFileName = fileName.toLowerCase();
      final isVideo = lowerFileName.endsWith('.mp4') ||
                      lowerFileName.endsWith('.mov') ||
                      lowerFileName.endsWith('.avi') ||
                      task.url.toLowerCase().contains('.mp4');

      try {
        if (isVideo) {
          debugPrint('Calling Gal.putVideo...');
          await Gal.putVideo(filePath, album: 'Nexus Downloader');
        } else {
          debugPrint('Calling Gal.putImage...');
          await Gal.putImage(filePath, album: 'Nexus Downloader');
        }
        debugPrint('Gal.put success for $fileName');

        await NotificationService.showDownloadCompleteNotification(
          fileName: fileName,
        );

        if (await file.exists()) {
          await file.delete();
          debugPrint('Cleaned up source file: $filePath');
        }
      } on GalException catch (ge) {
        debugPrint('GalException [${ge.type}]: ${ge.toString()}');
      } catch (e) {
        debugPrint('Gallery save error: $e');
      }
    } catch (e) {
      debugPrint('Completion handler error: $e');
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
      debugPrint('Requesting download for: $url');

      if (!await checkInternet()) {
        onError('No internet connection.');
        return null;
      }

      final hasAccess = await Gal.hasAccess(toAlbum: true);
      debugPrint('Gallery access: $hasAccess');

      if (!hasAccess) {
        final granted = await Gal.requestAccess(toAlbum: true);
        debugPrint('Gallery access granted: $granted');
        if (!granted) {
          onError('Gallery access denied. Please enable it in settings.');
          return null;
        }
      }

      final appDir = await getApplicationDocumentsDirectory();
      final downloadPath = p.join(appDir.path, 'downloads');
      final dir = Directory(downloadPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
        debugPrint('Created download directory: $downloadPath');
      }

      // Cleanup existing task for same URL
      try {
        final existing = await FlutterDownloader.loadTasksWithRawQuery(
            query: "SELECT * FROM task WHERE url = '$url'");
        if (existing != null) {
          for (var t in existing) {
            debugPrint('Removing existing task for same URL: ${t.taskId}');
            await FlutterDownloader.remove(taskId: t.taskId, shouldDeleteContent: true);
          }
        }
      } catch (e) {
        debugPrint('Cleanup error: $e');
      }

      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: downloadPath,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: false,
        saveInPublicStorage: false,
      );

      if (taskId != null) {
        debugPrint('Task enqueued with ID: $taskId');
        onSuccess('Download started...');
        return taskId;
      } else {
        debugPrint('Error: FlutterDownloader.enqueue returned null');
        onError('Could not start download.');
        return null;
      }
    } catch (e) {
      debugPrint('downloadFile exception: $e');
      onError('Error: ${e.toString()}');
      return null;
    }
  }
}
