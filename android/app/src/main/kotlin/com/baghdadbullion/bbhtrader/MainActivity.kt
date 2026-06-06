package com.baghdadbullion.bbhtrader

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(IpassKycPlugin())
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        val engine = flutterEngine
        if (engine == null) {
            super.onRequestPermissionsResult(requestCode, permissions, grantResults)
            return
        }
        val handled = engine.activityControlSurface.onRequestPermissionsResult(
            requestCode,
            permissions,
            grantResults,
        )
        if (!handled) {
            super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        }
    }
}
