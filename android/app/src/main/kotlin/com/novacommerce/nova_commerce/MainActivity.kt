package com.novacommerce.nova_commerce

import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
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
}
