import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'widgets/ad_slider.dart';
import 'models/media_info.dart';
import 'services/media_extractor.dart';
import 'services/downloader_service.dart';
import 'terms_and_conditions_screen.dart';
import 'legal_disclaimer_view_screen.dart';
import 'about_us_screen.dart';
import 'styles/glass_styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;
  final Map<String, double> _downloadProgress = {};
  final Map<String, String> _urlToTaskId = {};
  final Set<String> _downloadingUrls = {};
  List<MediaInfo> _results = [];

  @override
  void initState() {
    super.initState();
    DownloaderService.addListener(_onDownloadUpdate);
  }

  @override
  void dispose() {
    DownloaderService.removeListener(_onDownloadUpdate);
    super.dispose();
  }

  void _onDownloadUpdate(String id, DownloadTaskStatus status, int progress) {
    if (!mounted) return;

    setState(() {
      String? targetUrl;
      _urlToTaskId.forEach((url, taskId) {
        if (taskId == id) targetUrl = url;
      });

      if (targetUrl != null) {
        _downloadProgress[targetUrl!] = progress / 100;

        if (status == DownloadTaskStatus.complete) {
          _downloadingUrls.remove(targetUrl);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saved to Gallery!')),
          );
        } else if (status == DownloadTaskStatus.failed) {
          _downloadingUrls.remove(targetUrl);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Download failed.')),
          );
        }
      }
    });
  }

  void _processLink() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a link')),
      );
      return;
    }

    if (!await DownloaderService.checkInternet()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No internet connection. Please check your network settings.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _results = [];
    });

    try {
      final infos = await MediaExtractorService.extract(url);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _results = infos;
        if (infos.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not find any media at this link. Please make sure it is a public post.')),
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _downloadMedia(MediaInfo media) async {
    if (media.url == null) return;

    setState(() {
      _downloadingUrls.add(media.url!);
      _downloadProgress[media.url!] = 0;
    });

    String extension = media.type == MediaType.video ? 'mp4' : 'jpg';
    try {
      final uri = Uri.parse(media.url!);
      final path = uri.path.toLowerCase();
      if (path.endsWith('.webp')) {
        extension = 'webp';
      } else if (path.endsWith('.png')) {
        extension = 'png';
      } else if (path.endsWith('.mp4')) {
        extension = 'mp4';
      }
    } catch (_) {}

    final fileName = 'Nexus_${DateTime.now().millisecondsSinceEpoch}.$extension';

    final taskId = await DownloaderService.downloadFile(
      url: media.url!,
      fileName: fileName,
      isVideo: media.type == MediaType.video,
      onSuccess: (message) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _downloadingUrls.remove(media.url);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      },
    );

    if (taskId != null) {
      setState(() {
        _urlToTaskId[media.url!] = taskId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: GlassStyles.radialBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: Text(
                  'Nexus Media Downloader',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[900],
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: GlassStyles.inputBlur, sigmaY: GlassStyles.inputBlur),
                          child: Container(
                            decoration: GlassStyles.glassPanelDecoration.copyWith(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: TextField(
                              controller: _urlController,
                              decoration: const InputDecoration(
                                hintText: 'Paste link here...',
                                border: InputBorder.none,
                                filled: false,
                                icon: Icon(Icons.link, color: Colors.blueGrey),
                              ),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _isLoading ? null : _processLink,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: GlassStyles.inputBlur, sigmaY: GlassStyles.inputBlur),
                            child: Container(
                              height: 56,
                              decoration: GlassStyles.glassPanelDecoration.copyWith(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              alignment: Alignment.center,
                              child: _isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text(
                                      'Process Link',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_results.isNotEmpty)
                        Column(
                          children: _results.map((res) => _buildResultCard(res)).toList(),
                        ),
                    ],
                  ),
                ),
              ),
              const AdSlider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFooterLink('About Us', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsScreen()));
                    }),
                    const Text(' | ', style: TextStyle(color: Colors.blueGrey, fontSize: 12)),
                    _buildFooterLink('Legal Disclaimer', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalDisclaimerViewScreen()));
                    }),
                    const Text(' | ', style: TextStyle(color: Colors.blueGrey, fontSize: 12)),
                    _buildFooterLink('Terms and Conditions', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsAndConditionsScreen()));
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLink(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.blueGrey,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildResultCard(MediaInfo media) {
    bool isDownloading = _downloadingUrls.contains(media.url);
    double progress = _downloadProgress[media.url] ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: GlassStyles.glassBlur, sigmaY: GlassStyles.glassBlur),
          child: Container(
            decoration: GlassStyles.glassPanelDecoration.copyWith(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 80,
                        height: 80,
                        color: Colors.black12,
                        child: media.thumbnailUrl != null
                            ? Image.network(
                                media.thumbnailUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
                              )
                            : Icon(
                                media.type == MediaType.video ? Icons.videocam : Icons.image,
                                color: Colors.blueGrey,
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            media.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  media.type.name.toUpperCase(),
                                  style: const TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(media.platform, style: TextStyle(color: Colors.blueGrey[600], fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (isDownloading)
                  Column(
                    children: [
                      LinearProgressIndicator(value: progress, borderRadius: BorderRadius.circular(4)),
                      const SizedBox(height: 4),
                      Text('${(progress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 10)),
                    ],
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () => _downloadMedia(media),
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Save to Gallery'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
