import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, compute;
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

// Conditionally import tflite_flutter only on non-web platforms
import 'package:tflite_flutter/tflite_flutter.dart'
    if (dart.library.html) 'image_classifier_service_web_stub.dart';

/// Service for classifying images using the RecyConnect TFLite model.
/// Uses the quantized MobileNetV2-based model for material classification.
class ImageClassifierService {
  static ImageClassifierService? _instance;
  dynamic _interpreter;
  List<String> _labels = [];
  bool _isInitialized = false;
  bool _initFailed = false;

  // Model expects 224x224 RGB images
  static const int inputSize = 224;
  static const int numChannels = 3;

  // Mapping from model labels to UI display names
  static const Map<String, String> _labelToDisplayName = {
    'clothing': 'Clothing',
    'e-waste': 'E-Waste',
    'glass': 'Glass',
    'metal': 'Metal',
    'other': 'Other',
    'paper': 'Paper',
    'plastic': 'Plastic',
  };

  ImageClassifierService._();

  /// Get singleton instance
  static ImageClassifierService get instance {
    _instance ??= ImageClassifierService._();
    return _instance!;
  }

  /// Whether the service is ready for classification
  bool get isReady => _isInitialized && !_initFailed;

  /// Initialize the model and labels. Call once at app start or before first use.
  Future<void> initialize() async {
    if (_isInitialized || _initFailed) return;

    // TFLite is not supported on web
    if (kIsWeb) {
      print('ImageClassifierService: TFLite not supported on web, skipping initialization');
      _initFailed = true;
      return;
    }

    try {
      // Load labels
      final labelsData = await rootBundle.loadString(
        'assets/recyconnect_outputs/labels.txt',
      );
      _labels = labelsData
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      // Load the quantized model (smaller, faster)
      _interpreter = await Interpreter.fromAsset(
        'assets/recyconnect_outputs/recyconnect_model_quantized.tflite',
      );

      _isInitialized = true;
      print('ImageClassifierService: Initialized with ${_labels.length} labels');
    } catch (e) {
      print('ImageClassifierService: Failed to initialize - $e');
      _initFailed = true;
    }
  }

  /// Classify an image file and return the result.
  /// Returns null if the service is not initialized or classification fails.
  Future<ClassificationResult?> classifyImage(File imageFile) async {
    if (!_isInitialized || _interpreter == null) {
      await initialize();
      if (!_isInitialized) return null;
    }

    try {
      // Read and decode the image
      final bytes = await imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: inputSize,
        targetHeight: inputSize,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;

      // Get pixel data as RGBA
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      image.dispose();
      
      if (byteData == null) return null;

      // Create input tensor via background isolate to prevent UI frame drops
      final input = await compute(_preprocessImage, byteData);

      // Run inference
      final output = List.generate(
        1,
        (_) => List.filled(_labels.length, 0.0),
      );
      _interpreter!.run(input, output);

      // Find the top prediction
      final probabilities = output[0];
      int maxIndex = 0;
      double maxProb = probabilities[0];
      for (int i = 1; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIndex = i;
        }
      }

      final label = _labels[maxIndex];
      final displayName = _labelToDisplayName[label] ?? label;
      final confidence = maxProb;

      return ClassificationResult(
        label: label,
        displayName: displayName,
        confidence: confidence,
      );
    } catch (e) {
      print('ImageClassifierService: Classification error - $e');
      return null;
    }
  }

  /// Get the display name for a model label
  static String getDisplayName(String label) {
    return _labelToDisplayName[label.toLowerCase()] ?? label;
  }

  /// Dispose resources
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
    _instance = null;
  }
}

/// Static top-level/isolate-compatible function for parsing raw bytes into a TFLite tensor 
List<List<List<List<double>>>> _preprocessImage(ByteData byteData) {
  return List.generate(
    1,
    (_) => List.generate(
      224,
      (y) => List.generate(
        224,
        (x) {
          final offset = (y * 224 + x) * 4; 
          final r = byteData.getUint8(offset) / 255.0;
          final g = byteData.getUint8(offset + 1) / 255.0;
          final b = byteData.getUint8(offset + 2) / 255.0;
          return [r, g, b];
        },
      ),
    ),
  );
}

/// Result of an image classification
class ClassificationResult {
  final String label;        // Raw model label (e.g., "e-waste")
  final String displayName;  // UI display name (e.g., "E-Waste")
  final double confidence;   // 0.0 to 1.0

  ClassificationResult({
    required this.label,
    required this.displayName,
    required this.confidence,
  });

  /// Confidence as a percentage string (e.g., "94%")
  String get confidencePercent => '${(confidence * 100).toStringAsFixed(0)}%';

  @override
  String toString() => '$displayName ($confidencePercent)';
}
