// Web-only camera screen — bypasses camera_web entirely
// Uses browser's getUserMedia API directly via dart:js_interop
import 'dart:js_interop';

import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui_web;

import '../../config/constants.dart';
import '../../config/providers.dart';

/// Registers the <video> element and starts the webcam stream via JS interop,
/// completely bypassing camera_web and its broken `.producer` access.
class WebCameraScreen extends ConsumerStatefulWidget {
  const WebCameraScreen({super.key});

  @override
  ConsumerState<WebCameraScreen> createState() => _WebCameraScreenState();
}

class _WebCameraScreenState extends ConsumerState<WebCameraScreen> {
  static int _viewCounter = 0;
  late final String _viewId;

  bool _isInitialized = false;
  bool _isDisposed = false;
  bool _viewRegistered = false;
  String _recognizedText = '...';
  double _confidence = 0.0;
  String? _errorMessage;

  web.HTMLVideoElement? _videoElement;
  web.MediaStream? _mediaStream;

  void _log(String stage, [String? message]) {
    if (!kDebugMode) {
      return;
    }
    final ts = DateTime.now().toIso8601String();
    debugPrint('[WebCameraScreen][$ts][$stage] ${message ?? ''}');
  }

  void _logError(String stage, Object error, [StackTrace? stackTrace]) {
    if (!kDebugMode) {
      return;
    }
    final ts = DateTime.now().toIso8601String();
    debugPrint('[WebCameraScreen][$ts][$stage][ERROR] $error');
    if (stackTrace != null) {
      debugPrint('[WebCameraScreen][$ts][$stage][STACK] $stackTrace');
    }
  }

  @override
  void initState() {
    super.initState();
    _viewId = 'beethoven-webcam-${_viewCounter++}';
    _log('initState', 'viewId=$_viewId');
    _registerViewAndStart();
  }

  Future<void> _registerViewAndStart() async {
    _log('registerView:start');
    // Create the <video> element
    final video =
        web.document.createElement('video') as web.HTMLVideoElement;
    video.autoplay = true;
    video.muted = true;
    video.setAttribute('playsinline', 'true');
    video.style.width = '100%';
    video.style.height = '100%';
    video.style.objectFit = 'cover';
    _videoElement = video;

    // Register as a platform view (only once per viewId)
    if (!_viewRegistered) {
      ui_web.platformViewRegistry.registerViewFactory(
        _viewId,
        (int id) => video,
      );
      _viewRegistered = true;
      _log('registerView:done', 'Factory registered for $_viewId');
    }

    await _startCamera(video);
  }

  Future<void> _startCamera(web.HTMLVideoElement video) async {
    try {
      _log('startCamera:start');
      // Load ML model
      final mlService = ref.read(mlServiceProvider);
      if (!mlService.isInitialized) {
        _log('startCamera:ml', 'Loading model ${MLModelConstants.webModelPath}');
        await mlService.loadModel(MLModelConstants.modelPath);
        _log('startCamera:ml', 'Model loaded');
      } else {
        _log('startCamera:ml', 'Model already initialized');
      }

      // getUserMedia via JS interop — avoids camera_web entirely
      _log('startCamera:media', 'Requesting getUserMedia');
      final stream = await web.window.navigator.mediaDevices
          .getUserMedia(web.MediaStreamConstraints(
        video: true.toJS,
        audio: false.toJS,
      ))
          .toDart;
      _log('startCamera:media', 'getUserMedia resolved');

      if (_isDisposed) {
        _log('startCamera:dispose', 'Disposed before stream attach');
        _stopStream(stream);
        return;
      }

      _mediaStream = stream;
      video.srcObject = stream;

      if (mounted) {
        setState(() => _isInitialized = true);
      }
      _log('startCamera:ready', 'Video stream attached');
    } catch (e, st) {
      _logError('startCamera', e, st);
      if (mounted) {
        setState(() => _errorMessage = 'Camera error: $e');
      }
    }
  }

  void _stopStream(web.MediaStream? stream) {
    _log('stopStream', 'Stopping media tracks');
    stream?.getTracks().toDart.forEach((track) => track.stop());
  }

  @override
  void dispose() {
    _log('dispose:start', 'Disposing WebCameraScreen');
    _isDisposed = true;
    _stopStream(_mediaStream);
    _videoElement?.srcObject = null;
    _log('dispose:done');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Language Detection')),
      body: _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.videocam_off, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _errorMessage = null;
                          _isInitialized = false;
                        });
                        _registerViewAndStart();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : !_isInitialized
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    // Native browser video element
                    SizedBox.expand(
                      child: HtmlElementView(viewType: _viewId),
                    ),
                    // Recognition overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.7),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recognized: $_recognizedText',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: _confidence,
                              minHeight: 8,
                              backgroundColor: Colors.grey[400],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _confidence > 0.7
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Confidence: ${(_confidence * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
