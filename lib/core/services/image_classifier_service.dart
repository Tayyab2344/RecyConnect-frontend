import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, compute, kDebugMode;
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

// Conditionally import tflite_flutter only on non-web platforms
import 'image_classifier_service_web_stub.dart' if (dart.library.io) 'package:tflite_flutter/tflite_flutter.dart';

import '../../features/listing/data/repositories/listing_repository_impl.dart';

/// Service for classifying images using a 3-tier fallback strategy:
///   Tier 1: Groq Vision API (via backend)
///   Tier 2: Google Gemini API (via backend)
///   Tier 3: On-device TFLite model (offline fallback)
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
  // New model (recyconnect_outputs) — 4 classes
  // Old model (recyconnect_outputs_old) had 7 classes: clothing, e-waste, glass, metal, other, paper, plastic
  static const Map<String, String> _labelToDisplayName = {
    'ewaste': 'E-Waste',
    'metal': 'Metal',
    'paper': 'Paper',
    'plastic': 'Plastic',
  };

  ImageClassifierService._();

  /// Get singleton instance
  static ImageClassifierService get instance {
    _instance ??= ImageClassifierService._();
    return _instance!;
  }

  /// Whether the TFLite service is ready for on-device classification
  bool get isReady => _isInitialized && !_initFailed;

  /// Initialize the TFLite model and labels. Call once at app start or before first use.
  Future<void> initialize() async {
    if (_isInitialized || _initFailed) return;

    // TFLite is not supported on web
    if (kIsWeb) {
      if (kDebugMode) print('ImageClassifierService: TFLite not supported on web, skipping initialization');
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
      if (kDebugMode) print('ImageClassifierService: Initialized with ${_labels.length} labels');
    } catch (e) {
      if (kDebugMode) print('ImageClassifierService: Failed to initialize - $e');
      _initFailed = true;
    }
  }

  /// Smart classification with 3-tier fallback:
  ///   1. Cloud API (Groq → Gemini via backend)
  ///   2. On-device TFLite
  ///
  /// [imageFile] is required for TFLite fallback.
  /// [imageBase64] is optional — if null, will be generated from imageFile for cloud API.
  Future<ClassificationResult?> classifyImageSmart(File imageFile, {String? imageBase64}) async {
    // ── Tier 1 & 2: Try cloud API (backend orchestrates Groq → Gemini) ──
    try {
      if (kDebugMode) print('ImageClassifierService: Trying cloud classification...');

      // Generate base64 from file if not provided
      String? base64ForCloud = imageBase64;
      if (base64ForCloud == null) {
        final bytes = await imageFile.readAsBytes();
        base64ForCloud = base64Encode(bytes);
      }

      final repository = ListingRepositoryImpl();
      final result = await repository.classifyImage(imageBase64: base64ForCloud);

      if (result.isSuccess && result.data != null) {
        final data = result.data!;
        final materialType = (data['materialType'] as String?)?.toLowerCase() ?? '';
        final confidence = (data['confidence'] as num?)?.toDouble() ?? 0.0;
        final source = data['source'] as String? ?? 'cloud';
        final description = data['description'] as String? ?? '';
        final category = data['category'] as String? ?? materialType;
        final condition = data['condition'] as String? ?? 'fair';
        final isRecyclable = data['isRecyclable'] as bool? ?? true;

        // Map to display name
        final displayName = _labelToDisplayName[materialType] ??
            materialType[0].toUpperCase() + materialType.substring(1);

        if (kDebugMode) {
          print('ImageClassifierService: Cloud ($source) classified as $displayName ($confidence)');
        }

        return ClassificationResult(
          label: materialType,
          displayName: displayName,
          confidence: confidence,
          source: source,
          description: description,
          category: category,
          condition: condition,
          isRecyclable: isRecyclable,
        );
      }
    } catch (e) {
      if (kDebugMode) print('ImageClassifierService: Cloud classification failed - $e');
    }

    // ── Tier 3: On-device TFLite fallback ──────────────────────────
    if (kDebugMode) print('ImageClassifierService: Falling back to TFLite on-device...');
    return _classifyWithTFLite(imageFile);
  }

  /// Original TFLite-only classification (now used as Tier 3 fallback).
  /// Kept public for backward compatibility.
  Future<ClassificationResult?> classifyImage(File imageFile) async {
    // Use the smart 3-tier fallback
    return classifyImageSmart(imageFile);
  }

  /// Pure TFLite on-device classification.
  Future<ClassificationResult?> _classifyWithTFLite(File imageFile) async {
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

      if (kDebugMode) {
        print('ImageClassifierService: TFLite classified as $displayName (${(confidence * 100).toStringAsFixed(0)}%)');
      }

      return ClassificationResult(
        label: label,
        displayName: displayName,
        confidence: confidence,
        source: 'tflite',
      );
    } catch (e) {
      if (kDebugMode) print('ImageClassifierService: TFLite classification error - $e');
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
  final String label;        // Raw model label (e.g., "ewaste")
  final String displayName;  // UI display name (e.g., "E-Waste")
  final double confidence;   // 0.0 to 1.0
  final String source;       // "groq", "gemini", or "tflite"
  final String? description; // AI-generated description (cloud only)
  final String? category;    // Sub-category (cloud only)
  final String? condition;   // Condition assessment (cloud only)
  final bool? isRecyclable;  // Recyclability flag (cloud only)

  ClassificationResult({
    required this.label,
    required this.displayName,
    required this.confidence,
    this.source = 'tflite',
    this.description,
    this.category,
    this.condition,
    this.isRecyclable,
  });

  /// Human-readable source name for UI display
  String get sourceDisplay {
    switch (source) {
      case 'groq':
        return 'Groq AI';
      case 'gemini':
        return 'Gemini AI';
      case 'tflite':
        return 'Device AI';
      default:
        return 'AI';
    }
  }

  /// Confidence as a percentage string (e.g., "94%")
  String get confidencePercent => '${(confidence * 100).toStringAsFixed(0)}%';

  @override
  String toString() => '$displayName ($confidencePercent via $sourceDisplay)';
}
