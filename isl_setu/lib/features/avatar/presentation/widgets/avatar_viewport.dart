import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/motion_frame.dart';
import '../../application/avatar_model_provider.dart';

class AvatarViewport extends ConsumerStatefulWidget {
  final MotionFrame? currentFrame;
  final bool isPlaying;

  const AvatarViewport({
    super.key,
    this.currentFrame,
    this.isPlaying = false,
  });

  @override
  ConsumerState<AvatarViewport> createState() => _AvatarViewportState();
}

class _AvatarViewportState extends ConsumerState<AvatarViewport> {
  late final WebViewController _controller;
  bool _isPageLoaded = false;
  bool _isPageFinished = false;
  String? _base64Glb;
  bool _modelSent = false;

  @override
  void initState() {
    super.initState();
    _loadModelAsset();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0D131C))
      ..setOnConsoleMessage((JavaScriptConsoleMessage message) {
        debugPrint('WebView Console [${message.level.name}]: ${message.message}');
      })
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView RESOURCE ERROR: ${error.description} (code: ${error.errorCode})');
          },
          onPageFinished: (String url) {
            debugPrint('WebView finished loading: $url');
            if (mounted) {
              setState(() {
                _isPageLoaded = true;
                _isPageFinished = true;
              });
              _sendModelToWebView();
              _updateWebViewPose();
            }
          },
        ),
      )
      ..loadFlutterAsset('assets/avatar.html');
  }

  Future<void> _loadModelAsset() async {
    try {
      debugPrint('Getting Avatar2.glb base64 from provider...');
      final String base64Glb = await ref.read(avatarModelBase64Provider.future);
      _base64Glb = base64Glb;
      debugPrint('Loaded Avatar2.glb successfully, base64 length: ${_base64Glb!.length}');
      if (mounted) {
        _sendModelToWebView();
      }
    } catch (e) {
      debugPrint('Error loading Avatar2.glb asset: $e');
    }
  }

  void _sendModelToWebView() {
    if (!_isPageFinished || _base64Glb == null || _modelSent) return;
    _modelSent = true;

    // Chunk size: 2 MB
    const int chunkSize = 2 * 1024 * 1024;
    final int totalLength = _base64Glb!.length;
    final int totalChunks = (totalLength / chunkSize).ceil();
    debugPrint('Sending base64 model in chunks of $chunkSize. Total length: $totalLength. Total chunks: $totalChunks');

    _sendChunks(0, chunkSize, totalLength, totalChunks, 0);
  }

  void _sendChunks(int start, int chunkSize, int totalLength, int totalChunks, int chunkIndex) {
    if (!mounted) return;

    if (start < totalLength) {
      final int end = (start + chunkSize < totalLength) ? start + chunkSize : totalLength;
      final String chunk = _base64Glb!.substring(start, end);
      final int currentChunkNum = chunkIndex + 1;

      _controller.runJavaScript('appendModelChunk("$chunk", $currentChunkNum, $totalChunks)').then((_) {
        _sendChunks(end, chunkSize, totalLength, totalChunks, currentChunkNum);
      }).catchError((error) {
        debugPrint('Error sending model chunk: $error');
      });
    } else {
      debugPrint('Finished sending all chunks. Calling finalizeModel()');
      _controller.runJavaScript('finalizeModel()');
    }
  }

  @override
  void didUpdateWidget(covariant AvatarViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentFrame != oldWidget.currentFrame) {
      _updateWebViewPose();
    }
  }

  void _updateWebViewPose() {
    if (!_isPageLoaded) return;
    
    final frame = widget.currentFrame;
    if (frame != null) {
      final jsonStr = jsonEncode(frame.toJson());
      _controller.runJavaScript('updatePose($jsonStr)');
    } else {
      _controller.runJavaScript('updatePose(null)');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 320,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF0D131C),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderDark, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 3D WebView Avatar Viewport
            Positioned.fill(
              child: WebViewWidget(controller: _controller),
            ),

            // Avatar Header Badge / Indicator
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.cardDark.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryTeal.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: widget.isPlaying ? AppColors.successGreen : AppColors.textMuted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.isPlaying ? 'PLAYING 3D ANIMATION' : 'AVATAR READY',
                      style: TextStyle(
                        color: widget.isPlaying ? AppColors.primaryTealLight : AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Avatar Model Name Badge
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.cardDark.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.person_3_rounded, size: 14, color: AppColors.primaryTeal),
                    SizedBox(width: 6),
                    Text(
                      'Avatar2 Rig',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
