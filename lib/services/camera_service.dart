import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'photos_service.dart';

/// Clean, simple camera service focused on taking photos
class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isInitializing = false;

  /// Get the current camera controller
  CameraController? get controller => _controller;

  /// Check if camera is initialized and ready
  bool get isInitialized => _isInitialized;

  /// Get list of available cameras
  List<CameraDescription> get cameras => _cameras;

  /// Initialize the camera service
  Future<bool> initialize() async {
    if (_isInitializing || _isInitialized) {
      return _isInitialized;
    }

    _isInitializing = true;
    
    try {
      debugPrint("📷 Initializing camera service...");

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        debugPrint("❌ No cameras found");
        _isInitializing = false;
        return false;
      }

      // Use back camera if available, otherwise use first camera
      final camera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      // Create camera controller
      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      // Initialize camera
      await _controller!.initialize();
      
      _isInitialized = true;
      _isInitializing = false;
      
      debugPrint("✅ Camera initialized successfully");
      return true;

    } catch (e) {
      debugPrint("❌ Camera initialization failed: $e");
      _isInitialized = false;
      _isInitializing = false;
      return false;
    }
  }

  /// Take a picture and return the image bytes
  Future<Uint8List?> takePicture() async {
    if (!_isInitialized || _controller == null) {
      debugPrint("❌ Camera not initialized");
      return null;
    }

    try {
      debugPrint("📸 Taking picture...");
      
      final XFile imageFile = await _controller!.takePicture();
      final bytes = await imageFile.readAsBytes();
      
      debugPrint("✅ Picture taken successfully (${bytes.length} bytes)");
      return bytes;

    } catch (e) {
      debugPrint("❌ Failed to take picture: $e");
      return null;
    }
  }

  /// Take a picture and save it to gallery
  Future<bool> takePictureAndSave({String? fileName}) async {
    try {
      final imageBytes = await takePicture();
      if (imageBytes == null) {
        return false;
      }

      return await PhotosService.saveImageToGallery(imageBytes, fileName: fileName);
      
    } catch (e) {
      debugPrint("❌ Failed to take picture and save: $e");
      return false;
    }
  }

  /// Switch between front and back cameras
  Future<bool> switchCamera() async {
    if (!_isInitialized || _controller == null || _cameras.length < 2) {
      return false;
    }

    try {
      debugPrint("🔄 Switching camera...");
      
      final currentDirection = _controller!.description.lensDirection;
      final newCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection != currentDirection,
        orElse: () => _cameras.first,
      );

      // Dispose current controller
      await _controller!.dispose();

      // Create new controller
      _controller = CameraController(
        newCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      // Initialize new controller
      await _controller!.initialize();
      
      debugPrint("✅ Camera switched successfully");
      return true;

    } catch (e) {
      debugPrint("❌ Failed to switch camera: $e");
      return false;
    }
  }

  /// Set flash mode
  Future<void> setFlashMode(FlashMode mode) async {
    if (_isInitialized && _controller != null) {
      try {
        await _controller!.setFlashMode(mode);
        debugPrint("✅ Flash mode set to: $mode");
      } catch (e) {
        debugPrint("❌ Failed to set flash mode: $e");
      }
    }
  }

  /// Get current flash mode
  FlashMode get flashMode {
    return _controller?.value.flashMode ?? FlashMode.auto;
  }

  /// Check if flash is available
  bool get hasFlash {
    return _controller?.description.lensDirection == CameraLensDirection.back;
  }

  /// Dispose camera resources
  Future<void> dispose() async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }
    _isInitialized = false;
    _isInitializing = false;
    debugPrint("🧹 Camera service disposed");
  }

  /// Test camera functionality
  Future<void> testCamera(BuildContext context) async {
    try {
      final success = await initialize();
      
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
              ? '✅ Camera initialized successfully!' 
              : '❌ Failed to initialize camera',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Camera test failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}