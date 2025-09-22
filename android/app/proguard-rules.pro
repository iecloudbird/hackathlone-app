# Flutter ProGuard Rules for Release Builds
# This file prevents critical Flutter and Dart code from being obfuscated

# Keep all Flutter and Dart classes
-keep class io.flutter.** { *; }
-keep class flutter.** { *; }

# Keep all Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep Supabase and HTTP classes
-keep class io.supabase.** { *; }
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }

# Keep notification classes
-keep class com.dexterous.** { *; }
-keep class me.leolin.** { *; }

# Keep JSON serialization classes
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep all model classes (prevents JSON parsing issues)
-keep class **$Properties

# Flutter specific rules
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep asset files access
-keep class android.content.res.AssetManager { *; }

# Prevent obfuscation of environment variables and configuration
-keep class **.*Config* { *; }
-keep class **.*Configuration* { *; }

# Keep reflection-based access (common in Flutter plugins)
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod

# Prevent warnings for missing classes
-dontwarn javax.annotation.**
-dontwarn kotlin.Unit
-dontwarn retrofit2.Platform$Java8
