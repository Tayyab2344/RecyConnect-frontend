// Web implementation for file download
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void downloadFile(String content, String filename, String mimeType) {
  final bytes = content.codeUnits;
  final blob = html.Blob([bytes], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}
