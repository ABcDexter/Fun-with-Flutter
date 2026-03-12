import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/ui/home_screen.dart';
import 'utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.info('App', 'main() started');

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    AppLogger.error('App', details.exception, details.stack, 'FlutterError');
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    AppLogger.error('App', error, stack, 'Uncaught');
    return true;
  };

  AppLogger.info('App', 'runApp() about to execute');

  runApp(
    const ProviderScope(
      child: BeethovenApp(),
    ),
  );
}

class BeethovenApp extends StatelessWidget {
  const BeethovenApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.info('App', 'BeethovenApp.build()');
    return MaterialApp(
      title: 'Beethoven - ISL to Voice',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6200EE),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6200EE),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
