// Mobile stub — WebCameraScreen is never used on non-web platforms,
// but this file must exist so the conditional import compiles on mobile.
import 'package:flutter/material.dart';

class WebCameraScreen extends StatelessWidget {
  const WebCameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Web camera not available on this platform.')),
    );
  }
}
