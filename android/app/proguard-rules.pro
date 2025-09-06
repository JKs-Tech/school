# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase rules
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# WebView rules
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable classes
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep R classes
-keep class **.R$* {
    public static <fields>;
}

# Keep custom application class
-keep class com.aitech.schoolerp.** { *; }

# Keep essential Android classes
-keep class android.support.v4.** { *; }
-keep class androidx.** { *; }

# Keep JSON classes
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep Retrofit/OkHttp classes
-keepattributes Signature
-keepattributes *Annotation*
-keep class retrofit2.** { *; }
-keepclasseswithmembers class * {
    @retrofit2.http.* <methods>;
}
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# Keep Razorpay classes
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

# Keep Stripe classes
-keep class com.stripe.android.** { *; }
-dontwarn com.stripe.android.**

# Keep Pusher classes
-keep class com.pusher.** { *; }
-dontwarn com.pusher.**

# Keep Syncfusion classes
-keep class com.syncfusion.** { *; }
-dontwarn com.syncfusion.**

# Keep file picker classes
-keep class com.mr.flutter.plugin.filepicker.** { *; }
-dontwarn com.mr.flutter.plugin.filepicker.**

# Keep permission handler classes
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

# Keep device info classes
-keep class dev.fluttercommunity.plus.device_info.** { *; }
-dontwarn dev.fluttercommunity.plus.device_info.**

# Keep connectivity classes
-keep class dev.fluttercommunity.plus.connectivity.** { *; }
-dontwarn dev.fluttercommunity.plus.connectivity.**

# Keep location classes
-keep class com.lyokone.location.** { *; }
-dontwarn com.lyokone.location.**

# Keep YouTube player classes
-keep class com.pawan.chat.flutterchatui.** { *; }
-dontwarn com.pawan.chat.flutterchatui.**

# Keep notification classes
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**

# Keep calendar classes
-keep class com.dooboolab.** { *; }
-dontwarn com.dooboolab.**

# Keep reorderable classes
-keep class com.hydrax.ramadan.reorderables.** { *; }
-dontwarn com.hydrax.ramadan.reorderables.**

# Keep emoji classes
-keep class com.pauldemarco.flutter_blue.** { *; }
-dontwarn com.pauldemarco.flutter_blue.**

# Keep map classes
-keep class org.flutter.plugin.** { *; }
-dontwarn org.flutter.plugin.**

# Keep cloud firestore classes
-keep class io.flutter.plugins.firebase.** { *; }
-dontwarn io.flutter.plugins.firebase.**

# Keep multidex classes
-keep class androidx.multidex.** { *; }
-dontwarn androidx.multidex.**

# Keep core ktx classes
-keep class androidx.core.** { *; }
-dontwarn androidx.core.**

# Keep appcompat classes
-keep class androidx.appcompat.** { *; }
-dontwarn androidx.appcompat.**

# General Android optimizations
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification

# Remove logging
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Keep enum values
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep generic signatures
-keepattributes Signature

# Keep annotations
-keepattributes *Annotation*

# Keep inner classes
-keep class **.R$* {
    <fields>;
}

# Remove unused code
-dontwarn android.support.**
-dontwarn androidx.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**

# Keep essential methods
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

# Keep onClick methods
-keepclassmembers class * extends android.app.Activity {
    public void *(android.view.View);
}

# Keep custom views
-keep public class * extends android.view.View {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
    public void set*(...);
    public *** get*();
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep JavaScript interface methods
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}