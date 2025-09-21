import 'dart:typed_data';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../services/photos_service.dart';

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
    final picked = await PhotosService.pickImageFromGallery();
    if (picked != null) {
      setState(() => _backgroundImage = picked);
    }
  }

  Future<void> _checkPermissions() async {
    await PhotosService.showPermissionStatusDialog(context);
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
      // Capture the widget as image
      RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0); // Higher quality
      var byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Check if we can save to gallery first
      final canSave = await PhotosService.canSaveImages();
      
      if (canSave) {
        // Try to save to gallery
        final success = await PhotosService.saveImageToGallery(
          pngBytes,
          fileName: "bible_verse_${DateTime.now().millisecondsSinceEpoch}",
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Verse saved to Photos!")),
          );
        } else {
          // Show alternative save options
          PhotosService.showAlternativeSaveDialog(
            context, 
            pngBytes, 
            fileName: "bible_verse_${DateTime.now().millisecondsSinceEpoch}",
          );
        }
      } else {
        // Show alternative save options immediately
        PhotosService.showAlternativeSaveDialog(
          context, 
          pngBytes, 
          fileName: "bible_verse_${DateTime.now().millisecondsSinceEpoch}",
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
