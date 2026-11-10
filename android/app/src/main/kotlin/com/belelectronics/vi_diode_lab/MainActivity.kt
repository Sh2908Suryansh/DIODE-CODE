package com.belelectronics.vi_diode_lab

import android.app.Activity
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var exportResult: MethodChannel.Result? = null
    private var exportText: String? = null
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "diode_lab/data")
            .setMethodCallHandler { call, result ->
                val preferences = getSharedPreferences("diode_lab_v2", MODE_PRIVATE)
                when (call.method) {
                    "load" -> result.success(preferences.getString("progress", null))
                    "save" -> {
                        val data = call.arguments as? String
                        if (data == null) result.error("invalid", "Missing progress data", null)
                        else if (preferences.edit().putString("progress", data).commit()) result.success(null)
                        else result.error("storage", "Could not save progress", null)
                    }
                    "exportCsv" -> {
                        if (exportResult != null) result.error("busy", "A save dialog is already open", null)
                        else {
                            exportResult = result
                            exportText = call.arguments as? String ?: ""
                            try {
                                val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                                    addCategory(Intent.CATEGORY_OPENABLE)
                                    type = "text/csv"
                                    putExtra(Intent.EXTRA_TITLE, "diode-lab-readings.csv")
                                }
                                startActivityForResult(intent, 4102)
                            } catch (e: Exception) {
                                exportResult = null; exportText = null
                                result.error("export", e.message, null)
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
    @Deprecated("Activity result callback for the platform save dialog")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != 4102) return
        val pending = exportResult ?: return
        val csv = exportText ?: ""
        exportResult = null; exportText = null
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) { pending.success(false); return }
        try {
            val stream = contentResolver.openOutputStream(uri, "wt")
                ?: throw IllegalStateException("Could not open the selected file")
            stream.use { it.write(("\uFEFF" + csv).toByteArray(Charsets.UTF_8)) }
            pending.success(true)
        } catch (e: Exception) { pending.error("export", e.message, null) }
    }
}
