import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode, debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import '../../config/constants.dart';
import '../../config/providers.dart';
import '../../utils/app_logger.dart';
import 'camera_screen_web.dart' if (dart.library.io) 'camera_screen_stub.dart' as camera_impl;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beethoven'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Section
              Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.record_voice_over,
                      size: 64,
                      color: Colors.purple,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Indian Sign Language\nto English Voice',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Main Action Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    AppLogger.info('HomeScreen', 'Start Translation tapped (kIsWeb=$kIsWeb)');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          if (kIsWeb) {
                            AppLogger.info('HomeScreen', 'Navigating to WebCameraScreen');
                            return const camera_impl.WebCameraScreen();
                          }
                          AppLogger.info('HomeScreen', 'Navigating to CameraScreen');
                          return const CameraScreen();
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.videocam),
                  label: const Text('Start Translation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Features Section
              Text(
                'Features',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                icon: Icons.videocam_off,
                title: 'Real-time Video Processing',
                description: 'Captures and processes video frames in real-time',
              ),
              const SizedBox(height: 12),
              _buildFeatureCard(
                icon: Icons.smart_toy,
                title: 'ML Model Integration',
                description: 'Uses TensorFlow Lite for on-device inference',
              ),
              const SizedBox(height: 12),
              _buildFeatureCard(
                icon: Icons.volume_up,
                title: 'Natural Text-to-Speech',
                description: 'Indian English accent voice synthesis',
              ),
              const SizedBox(height: 32),

              // Quick Start Section
              Text(
                'How It Works',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildStepCard('1', 'Position yourself in front of the camera'),
              _buildStepCard('2', 'Make Indian Sign Language gestures'),
              _buildStepCard('3', 'The app translates your signs to text'),
              _buildStepCard('4', 'Hear the English translation spoken aloud'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 48, color: Colors.purple),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(String step, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            child: Text(step),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isDisposed = false;
  String _recognizedText = '';
  double _confidence = 0.0;
  bool _isProcessing = false;
  int _lastProcessedMs = 0;
  int _processedFrameCount = 0;
  final List<List<List<List<num>>>> _frameBuffer = [];

  void _log(String stage, [String? message]) {
    if (!kDebugMode) {
      return;
    }
    final ts = DateTime.now().toIso8601String();
    debugPrint('[CameraScreen][$ts][$stage] ${message ?? ''}');
  }

  void _logError(String stage, Object error, [StackTrace? stackTrace]) {
    if (!kDebugMode) {
      return;
    }
    final ts = DateTime.now().toIso8601String();
    debugPrint('[CameraScreen][$ts][$stage][ERROR] $error');
    if (stackTrace != null) {
      debugPrint('[CameraScreen][$ts][$stage][STACK] $stackTrace');
    }
  }

  @override
  void initState() {
    super.initState();
    _log('initState', 'kIsWeb=$kIsWeb');
    if (!kIsWeb) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    _log('initializeCamera:start');
    if (kIsWeb) {
      _log('initializeCamera:skip', 'Web platform detected');
      return;
    }

    try {
      _log('initializeCamera:ml', 'Reading ML service');
      final mlService = ref.read(mlServiceProvider);
      if (!mlService.isInitialized) {
        _log('initializeCamera:ml', 'Loading model ${MLModelConstants.modelPath}');
        await mlService.loadModel(MLModelConstants.modelPath);
        _log('initializeCamera:ml', 'Model loaded');
      } else {
        _log('initializeCamera:ml', 'Model already initialized');
      }

      _log('initializeCamera:cameras', 'Querying available cameras');
      final cameras = await availableCameras();
      _log('initializeCamera:cameras', 'Found ${cameras.length} camera(s)');
      if (cameras.isEmpty) {
        throw Exception('No cameras available on this device');
      }

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      _log('initializeCamera:controller', 'Initializing CameraController');
      await controller.initialize();
      _log('initializeCamera:controller', 'Controller initialized');

      if (_isDisposed) {
        _log('initializeCamera:dispose', 'Widget disposed before init completion');
        await controller.dispose();
        return;
      }

      _controller = controller;
      if (mounted) setState(() => _isInitialized = true);
      _log('initializeCamera:ready', 'Camera UI initialized');

      // Start image stream for real-time processing
      _log('imageStream:start', 'Starting image stream');
      await _controller!.startImageStream((image) async {
        if (_isProcessing) {
          return;
        }

        final nowMs = DateTime.now().millisecondsSinceEpoch;
        if (nowMs - _lastProcessedMs < CameraConstants.processingInterval) {
          return;
        }
        _lastProcessedMs = nowMs;

        _isProcessing = true;
        try {
          final frame = _preprocessCameraImage(image);
          _frameBuffer.add(frame);
          if (_frameBuffer.length < 30) {
            return;
          }
          if (_frameBuffer.length > 30) {
            _frameBuffer.removeAt(0);
          }

          final input = [_frameBuffer.toList()];
          final predictions = await mlService.runInference3dcnn(input);
          int maxIndex = 0;
          double maxValue = predictions.first;
          for (int i = 1; i < predictions.length; i++) {
            if (predictions[i] > maxValue) {
              maxValue = predictions[i];
              maxIndex = i;
            }
          }

          if (!mounted) {
            return;
          }

          setState(() {
            _confidence = maxValue;
            if (_confidence >= MLModelConstants.confidenceThreshold) {
              _recognizedText = 'Class $maxIndex';
            } else {
              _recognizedText = '...';
            }
          });

          _processedFrameCount++;
          if (_processedFrameCount % 30 == 0) {
            _log(
              'inference:result',
              'frames=$_processedFrameCount class=$maxIndex confidence=${_confidence.toStringAsFixed(4)}',
            );
          }
        } catch (e, st) {
          _logError('imageStream:processing', e, st);
          if (!mounted) {
            return;
          }
          setState(() {
            _recognizedText = 'Error';
            _confidence = 0.0;
          });
        } finally {
          _isProcessing = false;
        }
      });
      _log('imageStream:started');
    } catch (e, st) {
      _logError('initializeCamera', e, st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _log('dispose:start', 'Disposing CameraScreen');
    _isDisposed = true;
    _controller?.dispose();
    _log('dispose:done');
    super.dispose();
  }

  List<List<List<num>>> _preprocessCameraImage(CameraImage image) {
    final converted = _convertYUV420(image);
    final resized = img.copyResize(
      converted,
      width: MLModelConstants.inputWidth,
      height: MLModelConstants.inputHeight,
    );

    return List.generate(
      resized.height,
      (y) => List.generate(
        resized.width,
        (x) {
          final pixel = resized.getPixel(x, y);
          // don't use img.getRed/Green/Blue as it may be in ARGB format, use bitwise operations instead
          final r = pixel.r / 255.0;
          final g = pixel.g / 255.0;
          final b = pixel.b / 255.0;
          return [r, g, b];
        },
      ),
    );
  }

  img.Image _convertYUV420(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final uvRowStride = image.planes[1].bytesPerRow;
    final uvPixelStride = image.planes[1].bytesPerPixel ?? 1;
    final img.Image rgbImage = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      final uvRow = uvRowStride * (y >> 1);
      final yRow = image.planes[0].bytesPerRow * y;
      for (int x = 0; x < width; x++) {
        final uvIndex = uvRow + (x >> 1) * uvPixelStride;
        final yIndex = yRow + x;

        final int yValue = image.planes[0].bytes[yIndex];
        final int uValue = image.planes[1].bytes[uvIndex];
        final int vValue = image.planes[2].bytes[uvIndex];

        final double yDouble = yValue.toDouble();
        final double uDouble = uValue.toDouble() - 128.0;
        final double vDouble = vValue.toDouble() - 128.0;

        int r = (yDouble + 1.402 * vDouble).round();
        int g = (yDouble - 0.344136 * uDouble - 0.714136 * vDouble).round();
        int b = (yDouble + 1.772 * uDouble).round();

        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        rgbImage.setPixelRgb(x, y, r, g, b);
      }
    }

    return rgbImage;
  }

  @override
  Widget build(BuildContext context) {
    _log('build', 'kIsWeb=$kIsWeb isInitialized=$_isInitialized');
    if (kIsWeb) {
      return const camera_impl.WebCameraScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Language Detection'),
      ),
      body: _isInitialized
          ? Stack(
              children: [
                // Camera Preview
                CameraPreview(_controller!),

                // Overlay with recognized text
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
                            _confidence > 0.7 ? Colors.green : Colors.orange,
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
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
