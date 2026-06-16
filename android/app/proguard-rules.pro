# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class com.google.firebase.** { *; }

# Flutter Downloader
-keep class vn.hunghd.flutterdownloader.** { *; }

# InAppWebView
-keep class com.pichillilorenzo.flutter_inappwebview_android.** { *; }

# Connectivity Plus
-keep class dev.fluttercommunity.plus.connectivity.** { *; }

# Generated code
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Prevent obfuscation of certain Flutter internal classes
-keep class io.flutter.embedding.engine.plugins.FlutterPlugin { *; }
-keep class io.flutter.embedding.engine.plugins.activity.ActivityAware { *; }
-keep class io.flutter.embedding.engine.plugins.service.ServiceAware { *; }

# JNI
-keep class com.github.dart_lang.jni.** { *; }
-keep class com.github.dart_lang.jni_flutter.** { *; }
