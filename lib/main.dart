import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'services/notification_service.dart';
import 'services/language_service.dart';
import 'services/database_service.dart';
import 'providers/app_state_provider.dart';
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
    
    // Initialize services
    bool databaseSuccess = false;
    bool notificationSuccess = false;
    
    try {
      await DatabaseService.initialize();
      databaseSuccess = true;
      print('✅ Database service initialized successfully');
    } catch (error) {
      print('⚠️ Database service initialization failed: $error');
    }
    
    try {
      notificationSuccess = await NotificationService().init();
      if (notificationSuccess) {
        print('✅ Notification service initialized successfully');
      }
    } catch (error) {
      print('⚠️ Notification service initialization failed: $error');
    }
    
    if (databaseSuccess && notificationSuccess) {
      print('✅ All services initialized successfully');
    } else {
      print('⚠️ Some services failed to initialize, but app will continue');
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
    return ChangeNotifierProvider(
      create: (context) => AppStateProvider()..initialize(),
      child: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return MaterialApp(
            title: 'Bible App',
            theme: ThemeData(
              primarySwatch: Colors.deepPurple,
              useMaterial3: true,
            ),
            locale: appState.currentLocale,
            supportedLocales: LanguageService.instance.allLanguages.map((lang) => lang.locale),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
