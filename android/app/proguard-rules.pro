# ML Kit Fixes
-dontwarn com.google.mlkit.**
-keep class com.google.mlkit.** { *; }

# TensorFlow Lite Fixes
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options
-dontwarn org.tensorflow.lite.**
-keep class org.tensorflow.lite.** { *; }
