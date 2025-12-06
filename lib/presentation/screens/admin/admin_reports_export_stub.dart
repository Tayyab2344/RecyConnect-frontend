// Stub implementation for non-web platforms
void downloadFile(String content, String filename, String mimeType) {
  // On mobile/desktop, this would use path_provider and file saving
  // For now, this is a no-op stub
  throw UnimplementedError('File download not implemented for this platform');
}
