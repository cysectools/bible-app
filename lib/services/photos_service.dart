import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Modern, clean photos service focused on gallery_saver and photo_manager
class PhotosService {
  // Private constructor to prevent instantiation
  PhotosService._();

  /// Save image to gallery using the most reliable method
  static Future<bool> saveImageToGallery(Uint8List imageBytes, {String? fileName}) async {
    try {
      debugPrint("💾 Starting image save process...");
      
      // Create temporary file
      final tempFile = await _createTempFile(imageBytes, fileName);
      if (tempFile == null) {
        debugPrint("❌ Failed to create temporary file");
        return false;
      }

      // Try different saving methods based on platform
      bool success = false;
      
      if (Platform.isIOS) {
        success = await _saveImageIOS(tempFile);
      } else if (Platform.isAndroid) {
        success = await _saveImageAndroid(tempFile);
      }

      // Clean up temporary file
      await _cleanupTempFile(tempFile);
      
      if (success) {
        debugPrint("✅ Image saved to gallery successfully");
      } else {
        debugPrint("❌ Failed to save image to gallery");
      }
      
      return success;
      
    } catch (e) {
      debugPrint("❌ Error saving image: $e");
      return false;
    }
  }

  /// Save image on iOS using multiple fallback methods
  static Future<bool> _saveImageIOS(File tempFile) async {
    // Method 1: Try photo_manager (most reliable for iOS)
    if (await _saveWithPhotoManager(tempFile)) {
      return true;
    }

    // Method 2: Try gallery_saver
    if (await _saveWithGallerySaver(tempFile)) {
      return true;
    }

    // Method 3: Fallback to share_plus
    debugPrint("⚠️ Using share_plus fallback for iOS");
    try {
      await Share.shareXFiles([XFile(tempFile.path)], text: 'Bible Verse Image');
      return true;
    } catch (e) {
      debugPrint("❌ Share fallback failed: $e");
      return false;
    }
  }

  /// Save image on Android using gallery_saver
  static Future<bool> _saveImageAndroid(File tempFile) async {
    // Method 1: Try gallery_saver (primary for Android)
    if (await _saveWithGallerySaver(tempFile)) {
      return true;
    }

    // Method 2: Try photo_manager as fallback
    if (await _saveWithPhotoManager(tempFile)) {
      return true;
    }

    debugPrint("❌ All Android save methods failed");
    return false;
  }

  /// Save image using photo_manager
  static Future<bool> _saveWithPhotoManager(File imageFile) async {
    try {
      debugPrint("🔄 Trying photo_manager...");
      
      // Request permission
      final PermissionState permission = await PhotoManager.requestPermissionExtend();
      
      if (!permission.isAuth) {
        debugPrint("❌ Photo manager permission denied: $permission");
        return false;
      }

      // Save image
      final AssetEntity? asset = await PhotoManager.editor.saveImageWithPath(
        imageFile.path,
        title: "Bible Verse Image",
      );

      if (asset != null) {
        debugPrint("✅ Photo manager save successful");
        return true;
      } else {
        debugPrint("❌ Photo manager save failed - no asset returned");
        return false;
      }
      
    } catch (e) {
      debugPrint("❌ Photo manager error: $e");
      return false;
    }
  }

  /// Save image using gallery_saver
  static Future<bool> _saveWithGallerySaver(File imageFile) async {
    try {
      debugPrint("🔄 Trying gallery_saver...");
      
      final result = await GallerySaver.saveImage(imageFile.path);
      
      if (result == true) {
        debugPrint("✅ Gallery saver save successful");
        return true;
      } else {
        debugPrint("❌ Gallery saver save failed");
        return false;
      }
      
    } catch (e) {
      debugPrint("❌ Gallery saver error: $e");
      return false;
    }
  }

  /// Create temporary file from image bytes
  static Future<File?> _createTempFile(Uint8List imageBytes, String? fileName) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final finalFileName = fileName ?? "bible_verse_${DateTime.now().millisecondsSinceEpoch}.png";
      final tempFile = File('${tempDir.path}/$finalFileName');
      
      await tempFile.writeAsBytes(imageBytes);
      debugPrint("✅ Temporary file created: ${tempFile.path}");
      
      return tempFile;
    } catch (e) {
      debugPrint("❌ Failed to create temp file: $e");
      return null;
    }
  }

  /// Clean up temporary file
  static Future<void> _cleanupTempFile(File tempFile) async {
    try {
      if (await tempFile.exists()) {
        await tempFile.delete();
        debugPrint("🧹 Temporary file cleaned up");
      }
    } catch (e) {
      debugPrint("⚠️ Failed to cleanup temp file: $e");
    }
  }

  /// Check if we can save images (simple permission check)
  static Future<bool> canSaveImages() async {
    try {
      if (Platform.isIOS) {
        // Check photo_manager permission
        final permission = await PhotoManager.requestPermissionExtend();
        return permission.isAuth;
      } else {
        // For Android, assume we can save (gallery_saver handles permissions)
        return true;
      }
    } catch (e) {
      debugPrint("❌ Permission check failed: $e");
      return false;
    }
  }

  /// Show permission status dialog
  static Future<void> showPermissionDialog(BuildContext context) async {
    final canSave = await canSaveImages();
    
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Photo Permissions'),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text('Platform: ${Platform.isIOS ? 'iOS' : 'Android'}'),
              const SizedBox(height: 8),
            Text('Can Save Images: ${canSave ? 'Yes' : 'No'}'),
              const SizedBox(height: 16),
            Text(
              canSave 
                ? '✅ Your app has permission to save images to your photo library.'
                : '❌ Your app needs permission to save images. Please grant photo library access in your device settings.',
              style: TextStyle(
                color: canSave ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          if (!canSave)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Could add logic to open settings here
              },
              child: const Text('Open Settings'),
            ),
        ],
      ),
    );
  }

  /// Simple method to test image saving
  static Future<void> testImageSave(BuildContext context) async {
    try {
      // Create a simple test image (1x1 pixel PNG)
      final testImageBytes = Uint8List.fromList([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
        0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
        0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
        0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
        0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
        0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
      ]);

      final success = await saveImageToGallery(testImageBytes, fileName: 'test_image.png');
      
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
              ? '✅ Test image saved successfully!' 
              : '❌ Failed to save test image',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Test failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Show camera options dialog (for compatibility with existing code)
  static Future<Uint8List?> showCameraOptions(BuildContext context) async {
    try {
      // For now, return null since we removed image_picker
      // This can be enhanced later to use our camera service
      debugPrint("⚠️ showCameraOptions called - image picker not available in new implementation");
      return null;
    } catch (e) {
      debugPrint("❌ showCameraOptions error: $e");
      return null;
    }
  }

  /// Get detailed permission analysis (for compatibility)
  static Future<Map<String, dynamic>> getDetailedPermissionAnalysis() async {
    try {
      final canSave = await canSaveImages();
      
      return {
        'platform': Platform.isIOS ? 'iOS' : 'Android',
        'canSaveImages': canSave,
        'canPickImages': false, // image_picker removed
        'accessLevel': canSave ? 'Full Access' : 'No Access',
        'explanation': canSave 
          ? 'You have permission to save images to your photo library.'
          : 'You need to grant photo library permissions to save images.',
      };
    } catch (e) {
      debugPrint("❌ Permission analysis error: $e");
      return {
        'platform': Platform.isIOS ? 'iOS' : 'Android',
        'canSaveImages': false,
        'canPickImages': false,
        'accessLevel': 'Error',
        'explanation': 'Failed to check permissions: $e',
      };
    }
  }

  /// Show alternative save dialog (for compatibility)
  static Future<void> showAlternativeSaveDialog(
    BuildContext context, 
    Uint8List imageBytes, {
    String? fileName
  }) async {
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Image'),
        content: const Text('Choose how to save your image:'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Try saving again
              final success = await saveImageToGallery(imageBytes, fileName: fileName ?? "image.png");
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success 
                        ? '✅ Image saved successfully!' 
                        : '❌ Failed to save image',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Try Again'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Use share_plus as fallback
              try {
                final tempDir = await getTemporaryDirectory();
                final finalFileName = fileName ?? "image.png";
                final tempFile = File('${tempDir.path}/$finalFileName');
                await tempFile.writeAsBytes(imageBytes);
                
                await Share.shareXFiles([XFile(tempFile.path)], text: 'Bible Verse Image');
                
                // Clean up
                if (await tempFile.exists()) {
                  await tempFile.delete();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Share failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Share Instead'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}