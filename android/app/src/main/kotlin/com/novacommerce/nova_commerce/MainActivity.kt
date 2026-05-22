package com.novacommerce.nova_commerce

import android.os.Bundle
import android.util.Log
import androidx.appcompat.app.AppCompatDelegate
import androidx.core.os.LocaleListCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.novacommerce.nova_commerce/platform_app_locale"

    override fun onCreate(savedInstanceState: Bundle?) {
        try {
            val firebaseAppClass = Class.forName("com.google.firebase.FirebaseApp")
            val getAppsMethod = firebaseAppClass.getMethod("getApps", android.content.Context::class.java)
            val apps = getAppsMethod.invoke(null, this) as List<*>

            val defaultName = firebaseAppClass.getField("DEFAULT_APP_NAME").get(null) as String

            val names = apps.mapNotNull { app ->
                try {
                    val getName = app!!.javaClass.getMethod("getName")
                    getName.invoke(app) as? String
                } catch (_: Throwable) {
                    null
                }
            }

            val hasDefault = names.any { it == defaultName }
            Log.i(
                "NovaFirebase",
                "MainActivity.onCreate FirebaseApp.getApps.size=${apps.size} hasDefault=$hasDefault names=$names",
            )
        } catch (t: Throwable) {
            Log.e("NovaFirebase", "MainActivity.onCreate unable to query FirebaseApp", t)
        }

        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method != "setLocale") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }

                val tag = (call.argument<String>("languageTag") ?: "").trim()
                val locales = if (tag.isEmpty()) {
                    LocaleListCompat.getEmptyLocaleList()
                } else {
                    LocaleListCompat.forLanguageTags(tag)
                }

                AppCompatDelegate.setApplicationLocales(locales)
                result.success(null)
            }
    }
}
