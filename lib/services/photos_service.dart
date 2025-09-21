import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PhotosService {
  static final ImagePicker _imagePicker = ImagePicker();

  /// Initialize photos service and request necessary permissions
  static Future<bool> initialize() async {
    try {
      print("📸 Initializing PhotosService...");
      
      // Request permissions based on platform
      final hasPermission = await _requestPhotoPermissions();
      
      if (hasPermission) {
        print("✅ PhotosService initialized successfully");
      } else {
        print("⚠️ PhotosService initialized with limited permissions");
      }
      
      return hasPermission;
    } catch (e) {
      print("❌ Error initializing PhotosService: $e");
      return false;
    }
  }

  /// Request photo permissions for both iOS and Android
  static Future<bool> _requestPhotoPermissions() async {
    try {
      if (Platform.isIOS) {
        return await _requestIOSPermissions();
      } else if (Platform.isAndroid) {
        return await _requestAndroidPermissions();
      }
      return false;
    } catch (e) {
      print("❌ Error requesting photo permissions: $e");
      return false;
    }
  }

  /// Request iOS photo permissions
  static Future<bool> _requestIOSPermissions() async {
    try {
      // Request photosAddOnly permission (for saving images)
      PermissionStatus status = await Permission.photosAddOnly.status;
      print("📱 iOS Photos Add Only permission status: $status");
      
      if (status != PermissionStatus.granted) {
        status = await Permission.photosAddOnly.request();
        print("📱 iOS Photos Add Only permission after request: $status");
      }
      
      // Also check photos permission for reading
      final photosStatus = await Permission.photos.status;
      print("📱 iOS Photos permission status: $photosStatus");
      
      if (photosStatus != PermissionStatus.granted) {
        await Permission.photos.request();
        print("📱 iOS Photos permission after request: $photosStatus");
      }
      
      return status == PermissionStatus.granted;
    } catch (e) {
      print("❌ Error requesting iOS permissions: $e");
      return false;
    }
  }

  /// Request Android photo permissions
  static Future<bool> _requestAndroidPermissions() async {
    try {
      PermissionStatus status;
      
      // For Android 13+ (API 33+), use photos permission
      status = await Permission.photos.status;
      print("🤖 Android Photos permission status: $status");
      
      if (status != PermissionStatus.granted) {
        status = await Permission.photos.request();
        print("🤖 Android Photos permission after request: $status");
      }
      
      // Fallback to storage permission for older Android versions
      if (status != PermissionStatus.granted) {
        status = await Permission.storage.status;
        print("🤖 Android Storage permission status: $status");
        
        if (status != PermissionStatus.granted) {
          status = await Permission.storage.request();
          print("🤖 Android Storage permission after request: $status");
        }
      }
      
      return status == PermissionStatus.granted;
    } catch (e) {
      print("❌ Error requesting Android permissions: $e");
      return false;
    }
  }

  /// Check current photo permission status
  static Future<Map<String, PermissionStatus>> getPermissionStatus() async {
    final status = <String, PermissionStatus>{};
    
    if (Platform.isIOS) {
      status['photosAddOnly'] = await Permission.photosAddOnly.status;
      status['photos'] = await Permission.photos.status;
    } else if (Platform.isAndroid) {
      status['photos'] = await Permission.photos.status;
      status['storage'] = await Permission.storage.status;
    }
    
    return status;
  }

  /// Pick an image from gallery
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print("❌ Error picking image from gallery: $e");
      return null;
    }
  }

  /// Pick an image from camera
  static Future<File?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print("❌ Error picking image from camera: $e");
      return null;
    }
  }

  /// Save image to device gallery
  static Future<bool> saveImageToGallery(Uint8List imageBytes, {String? fileName}) async {
    try {
      // Check permissions before saving
      final hasPermission = await _checkSavePermissions();
      if (!hasPermission) {
        print("❌ No permission to save image to gallery");
        return false;
      }

      final result = await ImageGallerySaver.saveImage(
        imageBytes,
        name: fileName ?? "bible_verse_${DateTime.now().millisecondsSinceEpoch}",
        quality: 90,
      );

      if (result['isSuccess'] == true) {
        print("✅ Image saved to gallery successfully");
        return true;
      } else {
        print("❌ Failed to save image to gallery: ${result['errorMessage']}");
        return false;
      }
    } catch (e) {
      print("❌ Error saving image to gallery: $e");
      return false;
    }
  }

  /// Check if we have permission to save images
  static Future<bool> _checkSavePermissions() async {
    if (Platform.isIOS) {
      final status = await Permission.photosAddOnly.status;
      return status == PermissionStatus.granted;
    } else if (Platform.isAndroid) {
      final photosStatus = await Permission.photos.status;
      if (photosStatus == PermissionStatus.granted) return true;
      
      final storageStatus = await Permission.storage.status;
      return storageStatus == PermissionStatus.granted;
    }
    return false;
  }

  /// Save image to app's local directory
  static Future<String?> saveImageLocally(Uint8List imageBytes, {String? fileName}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final finalFileName = fileName ?? "bible_verse_${DateTime.now().millisecondsSinceEpoch}.png";
      final file = File('${directory.path}/$finalFileName');
      
      await file.writeAsBytes(imageBytes);
      print("✅ Image saved locally: ${file.path}");
      return file.path;
    } catch (e) {
      print("❌ Error saving image locally: $e");
      return null;
    }
  }

  /// Show permission dialog with helpful instructions
  static void showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Photos Access Required"),
        content: Text(
          Platform.isIOS
              ? "To save your verse images, you need Full Access to Photos.\n\n"
                "Current: Private Access (can only select photos)\n"
                "Needed: Full Access (can save images)\n\n"
                "To change this:\n"
                "1. Go to Privacy & Security → Photos\n"
                "2. Find 'Bible App' in the list\n"
                "3. Tap on 'Bible App'\n"
                "4. Change from 'Private Access' to 'Full Access'\n\n"
                "If you can't change it, try:\n"
                "• Delete and reinstall the app\n"
                "• Restart your device\n"
                "• Check if Screen Time restrictions are enabled"
              : "To save your verse images, you need Photos permission.\n\n"
                "Please grant Photos permission in your device settings.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  /// Show permission status dialog (for debugging)
  static Future<void> showPermissionStatusDialog(BuildContext context) async {
    final status = await getPermissionStatus();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Permission Status (${Platform.isIOS ? 'iOS' : 'Android'})"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: status.entries.map((entry) => 
            Text("${entry.key}: ${entry.value}")
          ).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  /// Check if we can save images (has proper permissions)
  static Future<bool> canSaveImages() async {
    return await _checkSavePermissions();
  }

  /// Check if we can pick images (has gallery access)
  static Future<bool> canPickImages() async {
    if (Platform.isIOS) {
      final status = await Permission.photos.status;
      return status == PermissionStatus.granted || status == PermissionStatus.limited;
    } else if (Platform.isAndroid) {
      final status = await Permission.photos.status;
      return status == PermissionStatus.granted;
    }
    return false;
  }

  /// Show alternative save options when full photo access isn't available
  static void showAlternativeSaveDialog(BuildContext context, Uint8List imageBytes, {String? fileName}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Save Options"),
        content: const Text(
          "Full photo access isn't available, but you can still save your verse image using these alternatives:",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Save to app's local storage
              final savedPath = await saveImageLocally(imageBytes, fileName: fileName);
              if (savedPath != null) {
                _showLocalSaveSuccessDialog(context, savedPath);
              }
            },
            child: const Text("Save to App Folder"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Try to save to gallery anyway (in case permissions changed)
              final success = await saveImageToGallery(imageBytes, fileName: fileName);
              if (!success) {
                // If still fails, show the permission dialog
                showPermissionDialog(context);
              }
            },
            child: const Text("Try Gallery Again"),
          ),
        ],
      ),
    );
  }

  /// Show success dialog for local save with sharing option
  static void _showLocalSaveSuccessDialog(BuildContext context, String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("✅ Image Saved!"),
        content: const Text(
          "Your verse image has been saved to the app's folder.\n\n"
          "You can access it through the Files app or share it using the button below.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _shareImageFile(context, filePath);
            },
            child: const Text("Share Image"),
          ),
        ],
      ),
    );
  }

  /// Share image file using the system share sheet
  static Future<void> _shareImageFile(BuildContext context, String filePath) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Check out this Bible verse!',
      );
    } catch (e) {
      // Fallback if sharing fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image saved to: $filePath")),
      );
    }
  }
}
