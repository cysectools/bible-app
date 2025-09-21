import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'services/photos_service.dart';
import 'screens/splash_screen.dart';
import 'utils/performance_monitor.dart';

void main() async {
  PerformanceMonitor.startTimer('app_launch');
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services in background to avoid blocking UI
  NotificationService().init().catchError((error) {
    print('Notification service initialization failed: $error');
  });
  
  PhotosService.initialize().catchError((error) {
    print('Photos service initialization failed: $error');
    return false;
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bible App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
