import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  static Future<File?> compressImage(File file, {int quality = 70}) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';
      
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: 800,
        minHeight: 800,
      );
      
      if (result != null) {
        if (kDebugMode) {
          final original = await file.length();
          final compressed = await result.length();
          if (kDebugMode) print('Image compressed: ${original / 1024} KB -> ${compressed / 1024} KB');
        }
        return File(result.path);
      }
      return file; 
    } catch (e) {
      if (kDebugMode) print('Compression failed: $e');
      return file;
    }
  }

  static Future<Uint8List> compressBytes(Uint8List bytes, {int quality = 70}) async {
    try {
      final result = await FlutterImageCompress.compressWithList(
        bytes,
        quality: quality,
        minWidth: 800,
        minHeight: 800,
      );
      if (kDebugMode) {
        if (kDebugMode) print('Bytes compressed: ${bytes.lengthInBytes / 1024} KB -> ${result.lengthInBytes / 1024} KB');
      }
      return result;
    } catch (e) {
      if (kDebugMode) print('Byte Compression failed: $e');
      return bytes;
    }
  }
}
