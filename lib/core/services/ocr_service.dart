import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  static final TextRecognizer _textRecognizer = TextRecognizer();

  static Future<String> extractTextFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      throw Exception('OCR failed: $e');
    }
  }

  static Future<Map<String, String>> extractCnicData(File imageFile) async {
    final text = await extractTextFromImage(imageFile);
    final Map<String, String> data = {};

    // Extract CNIC number (format: 12345-1234567-1)
    final cnicRegex = RegExp(r'\d{5}-\d{7}-\d{1}');
    final cnicMatch = cnicRegex.firstMatch(text);
    if (cnicMatch != null) {
      data['cnic'] = cnicMatch.group(0)!;
    }

    // Extract name (usually appears after "Name:" or similar)
    final nameRegex = RegExp(r'(?:Name|نام)[:\s]+([A-Za-z\s]+)', caseSensitive: false);
    final nameMatch = nameRegex.firstMatch(text);
    if (nameMatch != null) {
      data['name'] = nameMatch.group(1)!.trim();
    }

    // Extract father's name
    final fatherNameRegex = RegExp(r'(?:Father|والد)[:\s]+([A-Za-z\s]+)', caseSensitive: false);
    final fatherNameMatch = fatherNameRegex.firstMatch(text);
    if (fatherNameMatch != null) {
      data['fatherName'] = fatherNameMatch.group(1)!.trim();
    }

    return data;
  }

  static Future<Map<String, String>> extractNtnData(File imageFile) async {
    final text = await extractTextFromImage(imageFile);
    final Map<String, String> data = {};

    // Extract NTN number
    final ntnRegex = RegExp(r'(?:NTN|Tax)[:\s]*(\d{7,10})', caseSensitive: false);
    final ntnMatch = ntnRegex.firstMatch(text);
    if (ntnMatch != null) {
      data['ntn'] = ntnMatch.group(1)!;
    }

    return data;
  }

  static void dispose() {
    _textRecognizer.close();
  }
}
