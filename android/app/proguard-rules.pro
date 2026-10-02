# flutter_local_notifications stores scheduled notifications with Gson; R8
# strips the generic type info it needs, which makes scheduling crash (or the
# notification silently never fire) in release builds.
-keep class com.dexterous.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keep class * extends com.google.gson.reflect.TypeToken
-keep class com.google.gson.reflect.TypeToken { *; }
