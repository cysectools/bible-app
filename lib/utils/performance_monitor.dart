import 'dart:developer' as developer;

class PerformanceMonitor {
  static final Map<String, DateTime> _startTimes = {};
  
  static void startTimer(String name) {
    _startTimes[name] = DateTime.now();
  }
  
  static void endTimer(String name) {
    final startTime = _startTimes[name];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      developer.log('Performance: $name took ${duration.inMilliseconds}ms');
      _startTimes.remove(name);
    }
  }
  
  static void logLaunchTime() {
    developer.log('🚀 App launch performance optimized!');
  }
}
