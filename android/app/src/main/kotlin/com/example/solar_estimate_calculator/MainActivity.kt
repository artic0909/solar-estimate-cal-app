package com.example.solar_estimate_calculator

import android.content.ContentValues
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.websol.solar_estimate_calculator/storage"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "saveToPublicDownloads") {
                val fileName = call.argument<String>("fileName")
                val bytes = call.argument<ByteArray>("bytes")
                val mimeType = call.argument<String>("mimeType") ?: "application/octet-stream"

                if (fileName != null && bytes != null) {
                    val success = saveFileToDownloads(fileName, bytes, mimeType)
                    result.success(success)
                } else {
                    result.error("INVALID_ARGS", "fileName or bytes was null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun saveFileToDownloads(fileName: String, bytes: ByteArray, mimeType: String): Boolean {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val resolver = applicationContext.contentResolver

                // Check if file already exists in MediaStore Downloads to overwrite it
                val projection = arrayOf(MediaStore.MediaColumns._ID)
                val selection = "${MediaStore.MediaColumns.DISPLAY_NAME} = ? AND ${MediaStore.MediaColumns.RELATIVE_PATH} LIKE ?"
                val selectionArgs = arrayOf(fileName, "${Environment.DIRECTORY_DOWNLOADS}%")
                val queryUri = MediaStore.Downloads.EXTERNAL_CONTENT_URI

                var existingUri: Uri? = null
                resolver.query(queryUri, projection, selection, selectionArgs, null)?.use { cursor ->
                    if (cursor.moveToFirst()) {
                        val idIndex = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns._ID)
                        val id = cursor.getLong(idIndex)
                        existingUri = Uri.withAppendedPath(queryUri, id.toString())
                    }
                }

                val targetUri = existingUri ?: run {
                    val contentValues = ContentValues().apply {
                        put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                        put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
                        put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
                    }
                    resolver.insert(queryUri, contentValues)
                }

                if (targetUri != null) {
                    resolver.openOutputStream(targetUri, "wt")?.use { outputStream ->
                        outputStream.write(bytes)
                        outputStream.flush()
                    }
                    return true
                }
            }

            // Fallback for older Android or direct file system access
            val downloadsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
            if (!downloadsDir.exists()) {
                downloadsDir.mkdirs()
            }
            val targetFile = File(downloadsDir, fileName)
            FileOutputStream(targetFile).use { fos ->
                fos.write(bytes)
                fos.flush()
            }
            MediaScannerConnection.scanFile(
                applicationContext,
                arrayOf(targetFile.absolutePath),
                arrayOf(mimeType),
                null
            )
            return true
        } catch (e: Exception) {
            e.printStackTrace()
            try {
                val extDir = getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS)
                if (extDir != null) {
                    val fallbackFile = File(extDir, fileName)
                    FileOutputStream(fallbackFile).use { fos ->
                        fos.write(bytes)
                        fos.flush()
                    }
                    return true
                }
            } catch (ignored: Exception) {}
            return false
        }
    }
}
