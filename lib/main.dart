import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';
import 'utils/performance_monitor.dart';

void main() async {
  PerformanceMonitor.startTimer('app_launch');
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services with better error handling
  await _initializeServices();

  runApp(const MyApp());
}

Future<void> _initializeServices() async {
  try {
    print('🚀 Initializing Bible App services...');
    
    // Initialize notification service only (photos service doesn't need initialization)
    final notificationSuccess = await NotificationService().init().catchError((error) {
      print('⚠️ Notification service initialization failed: $error');
      return false;
    });
    
    if (notificationSuccess) {
      print('✅ Notification service initialized successfully');
    } else {
      print('⚠️ Notification service failed to initialize, but app will continue');
    }
    
  } catch (e) {
    print('❌ Error during service initialization: $e');
    // App will still run even if services fail
  }
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
