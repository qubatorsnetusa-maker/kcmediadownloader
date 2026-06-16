import 'package:flutter/material.dart';
import 'dart:ui';
import 'widgets/ad_slider.dart';
import 'models/media_info.dart';
import 'services/media_extractor.dart';
import 'services/downloader_service.dart';
import 'terms_and_conditions_screen.dart';
import 'legal_disclaimer_view_screen.dart';
import 'styles/glass_styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;
  double _downloadProgress = 0;
  bool _isDownloading = false;
  MediaInfo? _result;

  void _processLink() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a link')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final info = await MediaExtractorService.extract(url);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _result = info;
        if (info == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not extract media from this link.')),
          );
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _downloadMedia() async {
    if (_result == null || _result!.url == null) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    String extension = _result!.type == MediaType.video ? 'mp4' : 'jpg';
    try {
      final uri = Uri.parse(_result!.url!);
      final path = uri.path.toLowerCase();
      if (path.endsWith('.webp')) {
        extension = 'webp';
      } else if (path.endsWith('.png')) {
        extension = 'png';
      } else if (path.endsWith('.mp4') || (path.endsWith('.temp') && _result!.type == MediaType.video)) {
        extension = 'mp4';
      } else if (path.contains('.')) {
        final parts = path.split('.');
        final lastPart = parts.last;
        if (lastPart.length <= 4) {
          extension = lastPart;
        }
      }
    } catch (_) {}

    final fileName = 'KC_${DateTime.now().millisecondsSinceEpoch}.$extension';

    await DownloaderService.downloadFile(
      url: _result!.url!,
      fileName: fileName,
      isVideo: _result!.type == MediaType.video,
      onProgress: (count, total) {
        if (total > 0) {
          setState(() {
            _downloadProgress = count / total;
          });
        }
      },
      onSuccess: (path) {
        if (!mounted) return;
        setState(() => _isDownloading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Downloaded to: $path')),
        );
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isDownloading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      },
    );
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
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Text(
                  'KC Media Downloader',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.slate[900],
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
                      // URL Input with Glass Panel
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
                                hintText: 'https://www.kingsch.at/p/VjQ3Zjd',
                                border: InputBorder.none,
                                filled: false,
                                icon: Icon(Icons.link, color: Colors.slate),
                              ),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.medium),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Process Button
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
                      const SizedBox(height: 32),
                      if (_result != null) _buildResultCard(),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: AdSlider(),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFooterLink('Legal Disclaimer', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalDisclaimerViewScreen()));
                    }),
                    const Text(' | ', style: TextStyle(color: Colors.slate, fontSize: 12)),
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
          color: Colors.slate,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: GlassStyles.glassBlur, sigmaY: GlassStyles.glassBlur),
        child: Container(
          decoration: GlassStyles.glassPanelDecoration.copyWith(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🎬', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _result!.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildResultInfo('Platform', _result!.platform),
                  _buildResultInfo('Type', _result!.type.name.toUpperCase(), alignEnd: true),
                ],
              ),
              const SizedBox(height: 32),
              if (_isDownloading)
                Column(
                  children: [
                    LinearProgressIndicator(value: _downloadProgress),
                    const SizedBox(height: 8),
                    Text('${(_downloadProgress * 100).toStringAsFixed(0)}%'),
                  ],
                )
              else
                ElevatedButton.icon(
                  onPressed: _result?.url != null ? _downloadMedia : null,
                  icon: const Icon(Icons.download),
                  label: Text(_result?.url != null ? 'Download Media' : 'Direct Link Not Found'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.blue,
                    elevation: 0,
                    side: BorderSide(color: Colors.blue.withOpacity(0.2)),
                    shape: const StadiumBorder(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultInfo(String label, String value, {bool alignEnd = false}) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.slate[500],
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.slate[700],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
