# Implementation Plan - KC Media Downloader Flutter App

Build a Flutter application that allows users to download media (videos, images) from KingsChat and CeFlix links.

## User Review Required

- **CeFlix HLS Downloads**: Many CeFlix videos use HLS (`.m3u8`). Downloading HLS requires segment merging (usually via FFmpeg). For this initial version, I will focus on direct media links (MP4/JPG) and notify the user if only HLS is available, unless a simple HLS download library is found.
- **Storage Permissions**: The app will require storage permissions on Android.

## Proposed Changes

### Project Setup

- Initialized Flutter project with `http`, `dio`, `path_provider`, `permission_handler`, `carousel_slider`, and `flutter_inappwebview`.

---

### UI Components

#### [main.dart](file:///C:/Users/Kelvin Odems/AppData/Local/Google/AndroidStudio2025.3.4/projects/kcmediadownloader.6a317d40/lib/main.dart)
- Basic app configuration and theme.

#### [NEW] [home_screen.dart](file:///C:/Users/Kelvin Odems/AppData/Local/Google/AndroidStudio2025.3.4/projects/kcmediadownloader.6a317d40/lib/home_screen.dart)
- Search box for link entry.
- "Process Link" button.
- Result display (thumbnail, title, download button).
- Ad slider at the bottom.

#### [NEW] [ad_slider.dart](file:///C:/Users/Kelvin Odems/AppData/Local/Google/AndroidStudio2025.3.4/projects/kcmediadownloader.6a317d40/lib/widgets/ad_slider.dart)
- A carousel slider with placeholder advertisements.

---

### Logic and Services

#### [NEW] [media_extractor.dart](file:///C:/Users/Kelvin Odems/AppData/Local/Google/AndroidStudio2025.3.4/projects/kcmediadownloader.6a317d40/lib/services/media_extractor.dart)
- Logic to identify the platform (KingsChat or CeFlix).
- KingsChat: Parse HTML to find `window.__NUXT__` and extract `videoUrl` or `imageUrl`.
- CeFlix: Use `HeadlessInAppWebView` to intercept network calls and find media sources.

#### [NEW] [downloader_service.dart](file:///C:/Users/Kelvin Odems/AppData/Local/Google/AndroidStudio2025.3.4/projects/kcmediadownloader.6a317d40/lib/services/downloader_service.dart)
- Handles file downloading using `dio`.
- Manages storage permissions and file saving paths.

---

## Verification Plan

### Manual Verification
- **Test KingsChat Video**: Enter `https://kingschat.online/post/YTA1cEV` and verify it detects the MP4 and downloads it.
- **Test KingsChat Image**: Enter `https://kingschat.online/post/WGZPVGl` and verify it detects the image and downloads it.
- **Test CeFlix Video**: Enter `https://ceflix.org/videos/watch/1896191/medley-20---by-loveworld-singers` and verify it detects a media source.
- **Ad Slider**: Verify the slider scrolls through placeholders.
