import 'dart:js_util' as js_util;
import 'dart:js_interop';

import '../config/constants.dart';
import '../utils/app_logger.dart';

@JS('islTfjs')
external JSObject? get _islTfjs;

class ISLMLService {
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> loadModel(String modelPath) async {
    AppLogger.info('MLServiceWeb', 'loadModel() modelUrl=${MLModelConstants.webModelPath}');
    final modelUrl = MLModelConstants.webModelPath;
    final tfjs = _islTfjs;
    if (tfjs == null) {
      throw Exception('TFJS bridge not found. Ensure web/isl_tfjs.js is loaded.');
    }
    await js_util.promiseToFuture(
      js_util.callMethod(tfjs, 'loadModel', [modelUrl]),
    );
    _isInitialized = true;
    AppLogger.info('MLServiceWeb', 'Model loaded successfully');
  }

  Future<List<double>> runInference(List<List<List<List<num>>>> input) async {
    final tfjs = _islTfjs;
    if (!_isInitialized || tfjs == null) {
      throw Exception('Model not initialized');
    }
    try {
      final result = await js_util.promiseToFuture(
        js_util.callMethod(tfjs, 'predict', [input]),
      );
      return (result as List).map((e) => (e as num).toDouble()).toList();
    } catch (e, st) {
      AppLogger.error('MLServiceWeb', e, st, 'runInference');
      rethrow;
    }
  }

  Future<List<double>> runInference3dcnn(
    List<List<List<List<List<num>>>>> input,
  ) async {
    final tfjs = _islTfjs;
    if (!_isInitialized || tfjs == null) {
      throw Exception('Model not initialized');
    }
    try {
      final result = await js_util.promiseToFuture(
        js_util.callMethod(tfjs, 'predict', [input]),
      );
      return (result as List).map((e) => (e as num).toDouble()).toList();
    } catch (e, st) {
      AppLogger.error('MLServiceWeb', e, st, 'runInference3dcnn');
      rethrow;
    }
  }

  void dispose() {
    AppLogger.info('MLServiceWeb', 'dispose()');
    _isInitialized = false;
  }
}
