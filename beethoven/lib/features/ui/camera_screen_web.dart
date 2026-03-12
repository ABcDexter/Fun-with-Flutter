// Web-only camera screen — bypasses camera_web entirely
// Uses browser's getUserMedia API directly via dart:js_interop
import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late List<String> _classLabels = [];

  static int _viewCounter = 0;
  late final String _viewId;

  bool _isInitialized = false;
  bool _isDisposed = false;
  bool _viewRegistered = false;
  String _recognizedText = '...';
  double _confidence = 0.0;
  String? _errorMessage;
  bool _isProcessing = false;
  int _processedFrameCount = 0;

  web.HTMLVideoElement? _videoElement;
  web.MediaStream? _mediaStream;
  web.CanvasRenderingContext2D? _canvasContext;
  web.HTMLCanvasElement? _canvas;
  int? _inferenceLoopId;

  Future<void> _loadLabels() async {
    try {
      // For web, load label_map.json via HTTP from the web/models folder
      final response = await web.window.fetch('models/isl_tfjs/label_map.json'.toJS).toDart;
      if (!response.ok) {
        throw Exception('Failed to fetch label_map.json: ${response.status}');
      }
      final jsonStr = await response.text().toDart;
      final data = jsonDecode(jsonStr.toString()) as Map<String, dynamic>;
      final idToLabel = data['id_to_label'] as Map<String, dynamic>;
      final numClasses = data['num_classes'] as int? ?? idToLabel.length;
      
      // Build ordered list from id_to_label map by index
      final labels = <String>[];
      for (int i = 0; i < numClasses; i++) {
        final label = idToLabel[i.toString()];
        labels.add(label is String ? label : 'unknown_$i');
      }
      
      if (mounted) {
        setState(() {
          _classLabels = labels;
        });
      }
      _log('loadLabels', 'Loaded ${labels.length} classes: ${labels.take(10).join(", ")}...');
    } catch (e, st) {
      _logError('loadLabels', e, st);
      if (mounted) {
        setState(() {
          _classLabels = [];
        });
      }
    }
  }

  String _classNameForIndex(int index) {

    if (index >= 0 && index < _classLabels.length) {
      return _classLabels[index];
    }
    return 'unknown_$index'; // Fallback if index is out of bounds
  }

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

  /// Extract a frame from the video element via canvas
  List<List<List<num>>>? _extractFrameFromVideo() {
    if (_videoElement == null ||
        _canvas == null ||
        _canvasContext == null ||
        _videoElement!.videoWidth == 0 ||
        _videoElement!.videoHeight == 0) {
      return null;
    }

    try {
      // Draw current video frame to canvas
      _canvasContext!.drawImage(
        _videoElement! as web.CanvasImageSource,
        0,
        0,
      );

      // Get image data from canvas
      final imageData = _canvasContext!.getImageData(
        0,
        0,
        _canvas!.width,
        _canvas!.height,
      );
      final data = imageData.data.toDart;

      // Convert RGBA data to normalized RGB frame [H][W][3]
      final width = _canvas!.width;
      final height = _canvas!.height;
      final frame = List.generate(
        height,
        (y) => List.generate(
          width,
          (x) {
            final idx = (y * width + x) * 4; // RGBA is 4 bytes per pixel
            final r = data[idx] / 255.0;
            final g = data[idx + 1] / 255.0;
            final b = data[idx + 2] / 255.0;
            return [r, g, b];
          },
        ),
      );

      return frame;
    } catch (e) {
      _logError('extractFrame', e);
      return null;
    }
  }

  /// Start the inference loop — processes frames every ~100ms
  void _startInferenceLoop() {
    if (_isDisposed) {
      return;
    }

    void processFrame() {
      if (_isDisposed || _isProcessing) {
        return;
      }

      _isProcessing = true;
      _processFrameAsync();
    }

    _inferenceLoopId = web.window.setInterval(
      processFrame.toJS,
      (100).toJS,
    );

    _log('inferenceLoop:started', 'Loop ID: $_inferenceLoopId');
  }

  Future<void> _processFrameAsync() async {
    try {
      final frame = _extractFrameFromVideo();
      if (frame == null) {
        _isProcessing = false;
        return;
      }

      // Run inference on single frame (2D model, not 3D CNN)
      final mlService = ref.read(mlServiceProvider);
      final input = [frame];
      final predictions = await mlService.runInference(input);

      // Find max prediction
      int maxIndex = 0;
      double maxValue = predictions.first;
      for (int i = 1; i < predictions.length; i++) {
        if (predictions[i] > maxValue) {
          maxValue = predictions[i];
          maxIndex = i;
        }
      }

      if (!mounted) {
        _isProcessing = false;
        return;
      }

      setState(() {
        _confidence = maxValue;
        
        // Diagnostic: log label loading status
        if (_processedFrameCount == 0 || _processedFrameCount % 100 == 0) {
          _log(
            'inference:diagnostic',
            'Labels loaded: ${_classLabels.length}, predictions length: ${predictions.length}, maxIndex: $maxIndex, label: ${_classNameForIndex(maxIndex)}',
          );
        }
        
        _log(
          'inference:prediction',
          'frames=$_processedFrameCount class=${_classNameForIndex(maxIndex)}($maxIndex) confidence=${_confidence.toStringAsFixed(4)}',
        );
        if (_confidence >= MLModelConstants.confidenceThreshold) {
          _recognizedText = _classNameForIndex(maxIndex);
        } else {
          _recognizedText = '...';
        }
      });

      _processedFrameCount++;
      if (_processedFrameCount % 30 == 0) {
        _log(
          'inference:result',
          'frames=$_processedFrameCount class=${_classNameForIndex(maxIndex)}($maxIndex) confidence=${_confidence.toStringAsFixed(4)}',
        );
      }
    } catch (e, st) {
      _logError('inferenceLoop', e, st);
      if (mounted) {
        setState(() {
          _recognizedText = 'Error';
          _confidence = 0.0;
        });
      }
    } finally {
      _isProcessing = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _viewId = 'beethoven-webcam-${_viewCounter++}';
    _log('initState', 'viewId=$_viewId');
    _loadLabels();
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

      // Create hidden canvas for frame extraction
      _log('startCamera:canvas', 'Creating canvas for frame extraction');
      _canvas = web.document.createElement('canvas') as web.HTMLCanvasElement;
      _canvas!.width = MLModelConstants.inputWidth;
      _canvas!.height = MLModelConstants.inputHeight;
      _canvas!.style.display = 'none';
      _canvasContext = _canvas!.getContext('2d') as web.CanvasRenderingContext2D;
      _log('startCamera:canvas', 'Canvas created (${MLModelConstants.inputWidth}x${MLModelConstants.inputHeight})');

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

      // Start the inference loop
      _startInferenceLoop();
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
    
    // Stop inference loop
    if (_inferenceLoopId != null) {
      _log('dispose:loop', 'Clearing inference loop $_inferenceLoopId');
      web.window.clearInterval(_inferenceLoopId!);
    }
    
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
