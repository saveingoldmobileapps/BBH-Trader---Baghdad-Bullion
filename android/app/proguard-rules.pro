# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Gson (reflection models)
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# OkHttp / Okio
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-keep class okio.** { *; }

# iPass KYC SDK
-keep class com.sdk.ipassplussdk.** { *; }
-keep interface com.sdk.ipassplussdk.** { *; }
-keepclassmembers class com.sdk.ipassplussdk.** { *; }
-dontwarn com.sdk.ipassplussdk.**

# Regula Document Reader (pulled by iPass Core)
-keep class com.regula.** { *; }
-keep interface com.regula.** { *; }
-keepclassmembers class com.regula.** { *; }
-dontwarn com.regula.**

# AWS Amplify face liveness (used by iPass)
-keep class com.amplifyframework.** { *; }
-keep class aws.sdk.** { *; }
-keep class com.amazonaws.** { *; }
-dontwarn com.amplifyframework.**
-dontwarn aws.sdk.**
-dontwarn com.amazonaws.**

# TensorFlow Lite (liveness)
-keep class org.tensorflow.** { *; }
-dontwarn org.tensorflow.**

# Stripe
-keep class com.stripe.** { *; }
-keep interface com.stripe.** { *; }
-dontwarn com.stripe.**
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider

# HyperPay OPPWA + 3DS2
-keep class com.oppwa.** { *; }
-keep interface com.oppwa.** { *; }
-dontwarn com.oppwa.**
-keep class ipworks.** { *; }
-keep interface ipworks.** { *; }
-dontwarn ipworks.**

# Google Pay / Play Services Wallet
-keep class com.google.android.gms.wallet.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Sentry
-keep class io.sentry.** { *; }
-keepattributes LineNumberTable,SourceFile

# ShuftiPro (legacy KYC path)
-keep class com.shuftipro.** { *; }
-dontwarn com.shuftipro.**

# Syncfusion PDF / Pdfium
-keep class com.syncfusion.** { *; }
-keep class com.shockwave.** { *; }
-dontwarn com.syncfusion.**

# Lean SDK
-keep class com.leantech.** { *; }
-dontwarn com.leantech.**

# CameraX / ML Kit leftovers
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable / Serializable
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# App package / method channel bridge
-keep class com.baghdadbullion.bbhtrader.** { *; }
