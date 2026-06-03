// Web stub for tflite_flutter - provides the Interpreter class signature
// so the code compiles on web without the native FFI dependency.

class Interpreter {
  static Future<Interpreter> fromAsset(String assetName) async {
    throw UnsupportedError('TFLite is not supported on web');
  }

  void run(dynamic input, dynamic output) {
    throw UnsupportedError('TFLite is not supported on web');
  }

  void close() {}
}
