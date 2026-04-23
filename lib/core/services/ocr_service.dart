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

    // Extract CNIC number (format: 12345-1234567-1, tolerating spaces or missing hyphens due to blur)
    final cnicRegex = RegExp(r'(\d{5})[\s\-]*(\d{7})[\s\-]*(\d{1})');
    final cnicMatch = cnicRegex.firstMatch(text);
    if (cnicMatch != null) {
      data['cnic'] = '${cnicMatch.group(1)}-${cnicMatch.group(2)}-${cnicMatch.group(3)}';
    }

    // Extract name (tolerating blurry colons or newlines)
    final nameRegex =
        RegExp(r'(?:Name|نام|Nane)[\s:;\-\.]*([A-Za-z\s]+)', caseSensitive: false);
    final nameMatch = nameRegex.firstMatch(text);
    if (nameMatch != null) {
      data['name'] = nameMatch.group(1)!.trim().split('\n').first;
    }

    // Extract father's name (tolerating blurry colons or newlines)
    final fatherNameRegex =
        RegExp(r'(?:Father|والد|Husband)[\s:;\-\.]*([A-Za-z\s]+)', caseSensitive: false);
    final fatherNameMatch = fatherNameRegex.firstMatch(text);
    if (fatherNameMatch != null) {
      data['fatherName'] = fatherNameMatch.group(1)!.trim().split('\n').first;
    }

    return data;
  }

  static Future<Map<String, String>> extractNtnData(File imageFile) async {
    final rawText = await extractTextFromImage(imageFile);
    final Map<String, String> data = {};

    // Normalise: collapse multiple spaces/newlines into single space
    final text = rawText.replaceAll(RegExp(r'\s+'), ' ');

    // ── PRIORITY 1: NTN Number ─────────────────────────────────────────────
    // Real certificate label: "National Tax Number (NTN):"
    // Formats seen: "2942886-6"  (7 digits + dash + 1 digit)
    //               "2942886"    (7 digits only — dash may be missing/blurry)
    //               "29428866"   (all digits merged, no dash)
    final ntnPatterns = [
      // Label "National Tax Number" or "NTN" followed by the number
      RegExp(
        r'(?:National\s+Tax\s+Number|NTN|Tax\s+No|Tax\s+Number)[^\d]*'
        r'(\d{7}[\s\-]*\d{1,2}|\d{7,10})',
        caseSensitive: false,
      ),
      // Bare 7-digit + dash + 1-digit pattern anywhere (most distinctive format)
      RegExp(r'\b(\d{7}[\s\-]\d{1})\b'),
      // 7-digit standalone fallback
      RegExp(r'\b(\d{7})\b'),
    ];

    for (final pattern in ntnPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
        // Normalise: remove spaces, ensure canonical "XXXXXXX-X" format if possible
        final raw = match.group(1)!.replaceAll(RegExp(r'\s'), '');
        // If it's 8 digits with no dash, insert dash at position 7
        String normalised = raw;
        if (RegExp(r'^\d{8}$').hasMatch(raw)) {
          normalised = '${raw.substring(0, 7)}-${raw.substring(7)}';
        } else if (RegExp(r'^\d{7}-\d$').hasMatch(raw)) {
          normalised = raw; // already correct
        }
        data['ntn'] = normalised;
        break;
      }
    }

    // ── PRIORITY 2: Registration Number ───────────────────────────────────
    // Real certificate label: "CNIC/Firm Reg./Company Inc.Number:"
    // Format seen: "104/99-41091-B"
    if (!data.containsKey('ntn')) {
      final regPatterns = [
        // Label-anchored
        RegExp(
          r'(?:CNIC|Firm\s+Reg|Company\s+Inc|Registration|Reg\.?\s*No)[^\w]*'
          r'([A-Z0-9][A-Z0-9\/\-]{4,24})',
          caseSensitive: false,
        ),
        // Generic alphanumeric reference with slashes (e.g. 104/99-41091-B)
        RegExp(r'\b(\d{2,4}\/\d{2,4}[\-]\d{4,6}[\-][A-Z])\b'),
        // Alphanumeric code 6-20 chars
        RegExp(r'\b([A-Z0-9]{2,6}[\-\/][A-Z0-9]{2,15}(?:[\-\/][A-Z0-9]{1,10})?)\b'),
      ];

      for (final pattern in regPatterns) {
        final match = pattern.firstMatch(text);
        if (match != null && match.group(1) != null) {
          data['ntn'] = match.group(1)!.trim();
          break;
        }
      }
    }

    // ── PRIORITY 3: Any Reference / Serial Number ─────────────────────────
    // Last resort — pick the first standalone number that looks like a
    // document identifier (6-12 digits, possibly with a dash).
    if (!data.containsKey('ntn')) {
      final refPatterns = [
        RegExp(r'\b(\d{6,12}[\-]\d{1,4})\b'),  // e.g. 123456-7
        RegExp(r'\bRef(?:erence)?[^\d]*(\d{6,15})\b', caseSensitive: false),
        RegExp(r'\bSerial[^\d]*(\d{6,15})\b', caseSensitive: false),
        RegExp(r'\b(\d{8,12})\b'),               // any long number
      ];

      for (final pattern in refPatterns) {
        final match = pattern.firstMatch(text);
        if (match != null && match.group(1) != null) {
          data['ntn'] = match.group(1)!.trim();
          break;
        }
      }
    }

    return data;
  }


  static Future<Map<String, String>> extractUtilityBillData(
      File imageFile) async {
    final text = await extractTextFromImage(imageFile);
    final Map<String, String> data = {};

    // Extract utility bill number - try multiple patterns
    final patterns = [
      RegExp(
          r'(?:Account|Bill|Customer|Reference|Ref)[\s\-#:]*(?:No|Number|ID)?[\s\-#:]*([A-Z0-9\-]{8,20})',
          caseSensitive: false),
      RegExp(r'\b([A-Z]{2,4}\d{8,15})\b'), // Pattern like ABC12345678
      RegExp(r'\b(\d{10,15})\b'), // Just long numbers
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
        data['utilityBillNumber'] = match.group(1)!.trim();
        break;
      }
    }

    return data;
  }

  static void dispose() {
    _textRecognizer.close();
  }
}
