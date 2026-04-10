// ignore: deprecated_member_use
import 'dart:html' as html;

void downloadFile(String content, String filename, String mimeType) {
  final bytes = content.codeUnits;
  final blob = html.Blob([bytes], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.Url.revokeObjectUrl(url);
}
