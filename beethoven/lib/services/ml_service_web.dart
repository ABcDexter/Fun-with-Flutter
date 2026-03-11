import 'dart:js_util' as js_util;
import 'dart:js_interop';

import '../config/constants.dart';

@JS('islTfjs')
external JSObject? get _islTfjs;

class ISLMLService {
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> loadModel(String modelPath) async {
    final modelUrl = MLModelConstants.webModelPath;
    final tfjs = _islTfjs;
    if (tfjs == null) {
      throw Exception('TFJS bridge not found. Ensure web/isl_tfjs.js is loaded.');
    }
    await js_util.promiseToFuture(
      js_util.callMethod(tfjs, 'loadModel', [modelUrl]),
    );
    _isInitialized = true;
  }

  Future<List<double>> runInference(List<List<List<List<num>>>> input) async {
    final tfjs = _islTfjs;
    if (!_isInitialized || tfjs == null) {
      throw Exception('Model not initialized');
    }
    final result = await js_util.promiseToFuture(
      js_util.callMethod(tfjs, 'predict', [input]),
    );
    return (result as List).map((e) => (e as num).toDouble()).toList();
  }

  Future<List<double>> runInference3dcnn(
    List<List<List<List<List<num>>>>> input,
  ) async {
    final tfjs = _islTfjs;
    if (!_isInitialized || tfjs == null) {
      throw Exception('Model not initialized');
    }
    final result = await js_util.promiseToFuture(
      js_util.callMethod(tfjs, 'predict', [input]),
    );
    return (result as List).map((e) => (e as num).toDouble()).toList();
  }

  void dispose() {
    _isInitialized = false;
  }
}
