import 'package:flutter/material.dart';
import 'widgets/ad_slider.dart';
import 'models/media_info.dart';
import 'services/media_extractor.dart';
import 'services/downloader_service.dart';
import 'terms_and_conditions_screen.dart';
import 'legal_disclaimer_view_screen.dart';

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
        // Fallback for complex extensions like .webp?param=value
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
      appBar: AppBar(
        title: const Text('KC Media Downloader'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      hintText: 'www.kingsch.at/p/VjQ3Zjd',
                      prefixIcon: Icon(Icons.link),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _processLink,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Process Link'),
                  ),
                  const SizedBox(height: 32),
                  if (_result != null) _buildResultCard(),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: AdSlider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LegalDisclaimerViewScreen()),
                  );
                },
                child: Text(
                  'Legal Disclaimer',
                  style: TextStyle(
                    color: Colors.grey[600],
                    decoration: TextDecoration.underline,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                ' | ',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TermsAndConditionsScreen()),
                  );
                },
                child: Text(
                  'Terms and Conditions',
                  style: TextStyle(
                    color: Colors.grey[600],
                    decoration: TextDecoration.underline,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          if (_result?.thumbnailUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                _result!.thumbnailUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _result!.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Platform: ${_result!.platform}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      'Type: ${_result!.type.name.toUpperCase()}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
