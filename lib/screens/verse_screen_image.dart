import 'dart:typed_data';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class VerseImageScreen extends StatefulWidget {
  final String verse;
  const VerseImageScreen({super.key, required this.verse});

  @override
  State<VerseImageScreen> createState() => _VerseImageScreenState();
}

class _VerseImageScreenState extends State<VerseImageScreen> {
  final GlobalKey _globalKey = GlobalKey();
  File? _backgroundImage;
  Color _backgroundColor = Colors.blueGrey;

  Future<void> _pickBackground() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _backgroundImage = File(picked.path));
    }
  }

  Future<void> _checkPermissions() async {
    if (Platform.isIOS) {
      final photosAddOnly = await Permission.photosAddOnly.status;
      final photos = await Permission.photos.status;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Permission Status (iOS)"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("photosAddOnly: $photosAddOnly"),
              Text("photos: $photos"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      final photos = await Permission.photos.status;
      final storage = await Permission.storage.status;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Permission Status (Android)"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("photos: $photos"),
              Text("storage: $storage"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Save Options"),
        content: const Text(
          "Can't save to Photos due to permission restrictions.\n\n"
          "Choose how to save your verse image:",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _saveToAppFolder();
            },
            child: const Text("Save to App Folder"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text("Try Settings"),
          ),
        ],
      ),
    );
  }

  Future<void> _saveToAppFolder() async {
    try {
      // Capture the widget as image
      RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      var byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save to app's documents directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'bible_verse_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pngBytes);

      // Show success dialog with options
      _showSaveSuccessDialog(file, fileName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Error saving: $e")),
      );
    }
  }

  void _showSaveSuccessDialog(File file, String fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("✅ Image Saved!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Your verse image has been saved successfully."),
            const SizedBox(height: 12),
            const Text("To access your image:"),
            const SizedBox(height: 8),
            const Text("• Open the Files app"),
            const Text("• Go to 'On My iPhone'"),
            const Text("• Find 'Bible App' folder"),
            const Text("• Your image will be there"),
            const SizedBox(height: 12),
            const Text("Or use the Share button below to save it elsewhere."),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _shareImage(file);
            },
            child: const Text("Share Image"),
          ),
        ],
      ),
    );
  }

  Future<void> _shareImage(File file) async {
    try {
      // Use share_plus package for sharing
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Check out this Bible verse!',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Error sharing: $e")),
      );
    }
  }

  void _showLimitedAccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Photos Access Required"),
        content: const Text(
          "To save your verse images, you need Full Access to Photos.\n\n"
          "Current: Private Access (can only select photos)\n"
          "Needed: Full Access (can save new images)\n\n"
          "In Settings:\n"
          "1. Go to Privacy & Security → Photos\n"
          "2. Find 'Bible App'\n"
          "3. Change from 'Selected Photos' to 'All Photos'",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  Future<void> _pickColor() async {
    // Simple preset color picker via bottom sheet
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
    ];
    await showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: colors.map((c) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _backgroundImage = null; // color overrides image
                    _backgroundColor = c;
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black12),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _saveImage() async {
    try {
      // First check current permission status
      PermissionStatus status;
      if (Platform.isIOS) {
        status = await Permission.photosAddOnly.status;
        print("📱 iOS Photos permission status: $status");
        
        // If not granted, request it
        if (status != PermissionStatus.granted) {
          status = await Permission.photosAddOnly.request();
          print("📱 iOS Photos permission after request: $status");
        }
        
        // Check if user has limited access (Private Access) or denied
        if (status == PermissionStatus.limited || status == PermissionStatus.denied) {
          _showLimitedAccessDialog();
          return;
        }
      } else {
        // For Android, try photos first (Android 13+)
        status = await Permission.photos.status;
        print("🤖 Android Photos permission status: $status");
        
        if (status != PermissionStatus.granted) {
          status = await Permission.photos.request();
          print("🤖 Android Photos permission after request: $status");
        }
        
        // Fallback to storage for older Android versions
        if (status != PermissionStatus.granted) {
          status = await Permission.storage.status;
          print("🤖 Android Storage permission status: $status");
          
          if (status != PermissionStatus.granted) {
            status = await Permission.storage.request();
            print("🤖 Android Storage permission after request: $status");
          }
        }
      }

      print("🔍 Final permission status: $status");
      
      if (status != PermissionStatus.granted) {
        // Show dialog with options: try settings or save to app folder
        _showPermissionDeniedDialog();
        return;
      }

      // Capture the widget as image
      RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0); // Higher quality
      var byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save to gallery using image_gallery_saver
      final result = await ImageGallerySaver.saveImage(
        pngBytes,
        quality: 100,
        name: "bible_verse_${DateTime.now().millisecondsSinceEpoch}",
      );

      if (result['isSuccess'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Verse saved to Photos!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⚠️ Failed to save: ${result['errorMessage']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Error saving image: $e")),
      );
    }
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
                      ? DecorationImage(image: FileImage(_backgroundImage!), fit: BoxFit.cover)
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _pickBackground,
                icon: const Icon(Icons.image),
                label: const Text("Pick Background"),
              ),
              ElevatedButton.icon(
                onPressed: _pickColor,
                icon: const Icon(Icons.color_lens),
                label: const Text("Pick Color"),
              ),
              ElevatedButton.icon(
                onPressed: _saveImage,
                icon: const Icon(Icons.save),
                label: const Text("Save Image"),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _checkPermissions,
                child: const Text("Check Permissions (Debug)"),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
