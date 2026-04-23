# ML Kit Fixes
-dontwarn com.google.mlkit.**
-keep class com.google.mlkit.** { *; }

# TensorFlow Lite Fixes
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options
-dontwarn org.tensorflow.lite.**
-keep class org.tensorflow.lite.** { *; }

# Stripe Push Provisioning (not used in this app, suppress R8 missing class errors)
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider
