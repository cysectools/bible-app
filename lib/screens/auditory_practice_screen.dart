import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../widgets/animated_background.dart';

class AuditoryPracticeScreen extends StatefulWidget {
  final String verse;
  
  const AuditoryPracticeScreen({
    super.key,
    required this.verse,
  });

  @override
  _AuditoryPracticeScreenState createState() => _AuditoryPracticeScreenState();
}

class _AuditoryPracticeScreenState extends State<AuditoryPracticeScreen>
    with TickerProviderStateMixin {
  late FlutterTts _flutterTts;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  bool _isPlaying = false;
  bool _isPaused = false;
  double _speechRate = 1.0;
  String _currentVerse = "";
  List<String> _verseLines = [];
  int? _selectedLineIndex;

  @override
  void initState() {
    super.initState();
    _currentVerse = widget.verse;
    _parseVerseIntoLines();
    _initializeTts();
    _initializeAnimations();
  }

  void _parseVerseIntoLines() {
    // Split verse into lines, handling common verse formatting
    _verseLines = _currentVerse
        .split(RegExp(r'[.!?]\s*'))
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.trim())
        .toList();
    
    // If no sentences found, split by commas or just use the whole verse
    if (_verseLines.isEmpty) {
      _verseLines = _currentVerse
          .split(',')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => line.trim())
          .toList();
    }
    
    // If still no lines, use the whole verse as one line
    if (_verseLines.isEmpty) {
      _verseLines = [_currentVerse];
    }
  }

  void _initializeTts() async {
    _flutterTts = FlutterTts();
    
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(1.0);
    await _flutterTts.setVolume(1.0);
    
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isPlaying = false;
        _isPaused = false;
        _selectedLineIndex = null;
      });
    });
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _speak() async {
    if (_isPlaying && !_isPaused) {
      await _flutterTts.pause();
      setState(() {
        _isPaused = true;
      });
    } else if (_isPaused) {
      await _flutterTts.speak(_currentVerse);
      setState(() {
        _isPaused = false;
      });
    } else {
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.speak(_currentVerse);
      setState(() {
        _isPlaying = true;
        _isPaused = false;
      });
    }
  }

  Future<void> _speakLine(int lineIndex) async {
    if (lineIndex >= 0 && lineIndex < _verseLines.length) {
      final line = _verseLines[lineIndex];
      
      await _flutterTts.stop();
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.speak(line);
      
      setState(() {
        _selectedLineIndex = lineIndex;
        _isPlaying = true;
        _isPaused = false;
      });
    }
  }

  Future<void> _stop() async {
    await _flutterTts.stop();
    setState(() {
      _isPlaying = false;
      _isPaused = false;
      _selectedLineIndex = null; // Reset selected line when stopped
    });
  }

  void _setSpeechRate(double rate) async {
    _speechRate = rate;
    await _flutterTts.setSpeechRate(_speechRate);
    setState(() {});
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("🎧 Auditory Practice"),
          titleTextStyle: const TextStyle(
            color: Colors.deepPurple,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Verse display
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.deepPurple.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.volume_up,
                        size: 48,
                        color: Colors.deepPurple.withOpacity(0.7),
                      ),
                      const SizedBox(height: 20),
                      // Scrollable verse lines
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: _verseLines.asMap().entries.map((entry) {
                              final index = entry.key;
                              final line = entry.value;
                              final isSelected = _selectedLineIndex == index;
                              
                              return GestureDetector(
                                onTap: () => _speakLine(index),
                                child: Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? Colors.deepPurple.withOpacity(0.1)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected 
                                          ? Colors.deepPurple.withOpacity(0.3)
                                          : Colors.transparent,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Line number indicator
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: isSelected 
                                              ? Colors.deepPurple
                                              : Colors.deepPurple.withOpacity(0.3),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              color: isSelected 
                                                  ? Colors.white
                                                  : Colors.deepPurple,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Line text
                                      Expanded(
                                        child: Text(
                                          line,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.deepPurple,
                                            height: 1.4,
                                            fontWeight: isSelected 
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      // Play icon for the line
                                      Icon(
                                        Icons.volume_up,
                                        size: 20,
                                        color: isSelected 
                                            ? Colors.deepPurple
                                            : Colors.deepPurple.withOpacity(0.5),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Speed controls
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.deepPurple.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Speech Speed",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSpeedButton("Slow", 0.5, Icons.slow_motion_video),
                        _buildSpeedButton("Normal", 1.0, Icons.play_arrow),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Play/Pause button
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isPlaying && !_isPaused ? _pulseAnimation.value : 1.0,
                        child: ElevatedButton.icon(
                          onPressed: _speak,
                          icon: Icon(
                            _isPlaying && !_isPaused 
                                ? Icons.pause 
                                : _isPaused 
                                    ? Icons.play_arrow 
                                    : Icons.play_arrow,
                            size: 32,
                          ),
                          label: Text(
                            _isPlaying && !_isPaused 
                                ? "Pause" 
                                : _isPaused 
                                    ? "Restart" 
                                    : "Play",
                            style: const TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Stop button
                  ElevatedButton.icon(
                    onPressed: _isPlaying ? _stop : null,
                    icon: const Icon(Icons.stop, size: 32),
                    label: const Text(
                      "Stop",
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isPlaying 
                          ? Colors.red 
                          : Colors.white.withOpacity(0.3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.deepPurple,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Tap any line to hear it spoken individually, or use the main controls to play the entire verse. This helps with focused memorization practice.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.deepPurple.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedButton(String label, double rate, IconData icon) {
    final isSelected = _speechRate == rate;
    
    return GestureDetector(
      onTap: () => _setSpeechRate(rate),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.deepPurple 
              : Colors.deepPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.deepPurple.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? Colors.white 
                  : Colors.deepPurple,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected 
                    ? Colors.white 
                    : Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}