import 'dart:typed_data';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../services/simple_photos_service.dart';

class VerseImageScreen extends StatefulWidget {
  final String verse;
  const VerseImageScreen({super.key, required this.verse});

  @override
  State<VerseImageScreen> createState() => _VerseImageScreenState();
}

class _VerseImageScreenState extends State<VerseImageScreen> {
  final GlobalKey _globalKey = GlobalKey();
  Uint8List? _backgroundImage;
  Color _backgroundColor = Colors.blueGrey;

  Future<void> _pickBackground() async {
    // For now, disable background picking since we're focusing on saving
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Background picking temporarily disabled. Focus on saving verse images!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _checkPermissions() async {
    // Show detailed permission analysis
    final analysis = await SimplePhotosService.getDetailedPermissionAnalysis();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("🔍 Permission Analysis (${analysis['platform']})"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("📊 Access Level: ${analysis['accessLevel']}", 
                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Text(analysis['explanation'] ?? 'No explanation available.'),
              const SizedBox(height: 16),
              const Text("🔧 Technical Details:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...analysis.entries.where((entry) => entry.key != 'platform' && entry.key != 'accessLevel' && entry.key != 'explanation').map((entry) => 
                Text("• ${entry.key}: ${entry.value}")
              ).toList(),
              const SizedBox(height: 16),
              if (analysis['accessLevel'] == 'Private Access (Limited)') ...[
                const Text("⚠️ Apple Policy Limitation:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                const SizedBox(height: 8),
                const Text("iOS 'Private Access' is designed for privacy and security. Apps with Private Access can only read photos you specifically select, but cannot save new images to your photo library."),
                const SizedBox(height: 8),
                const Text("This is not a bug in your app - it's Apple's security policy working as intended."),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
          if (analysis['accessLevel'] == 'Private Access (Limited)')
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                SimplePhotosService.showPermissionDialog(context);
              },
              child: const Text("Try to Fix"),
            ),
        ],
      ),
    );
  }


  Future<void> _pickColor() async {
    // Expanded color palette for more options
    final colors = <Color>[
      Colors.blueGrey,
      Colors.black87,
      Colors.deepPurple,
      Colors.indigo,
      Colors.teal,
      Colors.orange,
      Colors.redAccent,
      Colors.green,
      Colors.white,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
      Colors.brown,
      Colors.grey,
      Colors.lightBlue,
      Colors.purple,
      Colors.lime,
      Colors.deepOrange,
    ];
    await showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choose Background Color",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Horizontally scrollable color options
              SizedBox(
                height: 60,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: colors.map((c) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _backgroundImage = null; // color overrides image
                              _backgroundColor = c;
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: c == _backgroundColor
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 24,
                                  )
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveImage() async {
    try {
      // Capture the widget as image
      RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0); // Higher quality
      var byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save using simple photos service
      final success = await SimplePhotosService.saveImageToGallery(
        pngBytes,
        fileName: "bible_verse_${DateTime.now().millisecondsSinceEpoch}.png",
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success 
                  ? "✅ Verse image saved successfully!" 
                  : "❌ Failed to save image"
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Error saving image: $e")),
      );
    }
  }

  Future<void> _testImageSave() async {
    await SimplePhotosService.testImageSave(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verse Image")),
      body: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              key: _globalKey,
              child: Container(
                decoration: BoxDecoration(
                  image: _backgroundImage != null
                      ? DecorationImage(image: MemoryImage(_backgroundImage!), fit: BoxFit.cover)
                      : null,
                  color: _backgroundColor,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      widget.verse,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Horizontally scrollable buttons for better mobile experience
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickBackground,
                    icon: const Icon(Icons.image),
                    label: const Text("Pick Background"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _pickColor,
                    icon: const Icon(Icons.color_lens),
                    label: const Text("Pick Color"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _saveImage,
                    icon: const Icon(Icons.save),
                    label: const Text("Save Image"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: _testImageSave,
                    child: const Text("Test Save"),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: _checkPermissions,
                    child: const Text("Debug Permissions"),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
