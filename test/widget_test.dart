import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kc_media_downloader/main.dart';

void main() {
  testWidgets('App basic UI test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KCMediaDownloaderApp(
      showWalkthrough: false,
      hasAcceptedLegal: true,
    ));

    // Verify that our title is present.
    expect(find.text('KC Media Downloader'), findsOneWidget);

    // Verify that the search box exists.
    expect(find.byType(TextField), findsOneWidget);

    // Verify that the process button exists.
    expect(find.text('Process Link'), findsOneWidget);
  });
}
