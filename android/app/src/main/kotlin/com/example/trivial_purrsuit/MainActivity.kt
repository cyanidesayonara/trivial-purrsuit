package com.example.trivial_purrsuit

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import android.window.OnBackInvokedDispatcher

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
            onBackInvokedDispatcher.registerOnBackInvokedCallback(
                OnBackInvokedDispatcher.PRIORITY_DEFAULT
            ) {
                // Do nothing to prevent back gesture
            }
        }
    }
}
