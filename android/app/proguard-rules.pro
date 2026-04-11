# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

# Google Play Core (deferred components)
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Google Play Billing
-keep class com.android.vending.billing.** { *; }

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }

# Google Play Games Services
-keep class com.google.android.gms.games.** { *; }

# Flame Audio / AudioPlayers
-keep class xyz.luan.audioplayers.** { *; }
