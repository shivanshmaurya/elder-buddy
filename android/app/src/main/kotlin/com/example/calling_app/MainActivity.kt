package com.example.calling_app

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.elderbuddy/direct_call"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "makeCall") {
                val phoneNumber = call.argument<String>("phoneNumber")
                if (phoneNumber != null) {
                    val success = makeDirectCall(phoneNumber)
                    result.success(success)
                } else {
                    result.error("INVALID_ARGUMENT", "Phone number is required", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun makeDirectCall(phoneNumber: String): Boolean {
        return try {
            val intent = Intent(Intent.ACTION_CALL)
            intent.data = Uri.parse("tel:$phoneNumber")
            startActivity(intent)
            true
        } catch (e: SecurityException) {
            // Permission not granted
            false
        } catch (e: Exception) {
            false
        }
    }
}
