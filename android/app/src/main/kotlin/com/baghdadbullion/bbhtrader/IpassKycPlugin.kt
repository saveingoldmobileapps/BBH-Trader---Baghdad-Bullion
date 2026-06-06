package com.baghdadbullion.bbhtrader

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.graphics.Color
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.gson.Gson
import com.sdk.ipassplussdk.apis.ResultListener
import com.sdk.ipassplussdk.core.DataBaseDownloading
import com.sdk.ipassplussdk.core.configProperties
import com.sdk.ipassplussdk.core.iPassSDKManger
import com.sdk.ipassplussdk.enums.DatabaseType
import com.sdk.ipassplussdk.model.response.authentication.AuthenticationResponse
import com.sdk.ipassplussdk.model.response.transaction_details.TransactionDetailResponse
import com.sdk.ipassplussdk.resultCallbacks.InitializeDatabaseCompletion
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import java.util.concurrent.atomic.AtomicBoolean

/**
 * Flutter method channel bridge for iPass KYC SDK (Android v2.17).
 * @see https://devdocs.ipass-mena.com/sdkDocumentation-v4.html
 */
class IpassKycPlugin :
    FlutterPlugin,
    MethodChannel.MethodCallHandler,
    ActivityAware,
    PluginRegistry.RequestPermissionsResultListener {

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var activityBinding: ActivityPluginBinding? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    private val gson = Gson()
    private val databaseReady = AtomicBoolean(false)

    private var scannerOverlay: FrameLayout? = null
    private var pendingKycAction: (() -> Unit)? = null
    private var pendingPermissionResult: MethodChannel.Result? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        activityBinding = binding
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        detachActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        activityBinding = binding
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivity() {
        detachActivity()
    }

    private fun detachActivity() {
        activityBinding?.removeRequestPermissionsResultListener(this)
        activityBinding = null
        activity = null
        clearScannerOverlay()
        pendingKycAction = null
        pendingPermissionResult = null
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ): Boolean {
        if (requestCode != KYC_PERMISSION_REQUEST_CODE) {
            return false
        }

        val allGranted = grantResults.isNotEmpty() &&
            grantResults.all { it == PackageManager.PERMISSION_GRANTED }

        mainHandler.post {
            if (allGranted) {
                pendingKycAction?.invoke()
            } else {
                pendingPermissionResult?.error(
                    "PERMISSION_DENIED",
                    "Camera and microphone permissions are required for identity verification.",
                    mapOf("permissions" to permissions.toList()),
                )
            }
            pendingKycAction = null
            pendingPermissionResult = null
        }
        return true
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            result.error(
                "UNSUPPORTED_SDK",
                "iPass KYC requires Android API 26 or higher.",
                null,
            )
            return
        }

        when (call.method) {
            "checkPermissions" -> handleCheckPermissions(result)
            "initializeDatabase" -> handleInitializeDatabase(call, result)
            "getWorkflows" -> handleGetWorkflows(result)
            "startKycVerification" -> handleStartKycVerification(call, result)
            else -> result.notImplemented()
        }
    }

    private fun handleCheckPermissions(result: MethodChannel.Result) {
        val act = activity
        if (act == null) {
            result.error("NO_ACTIVITY", "Activity is not available.", null)
            return
        }
        val missing = missingKycPermissions(act)
        result.success(
            mapOf(
                "granted" to missing.isEmpty(),
                "missing" to missing.toList(),
            ),
        )
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun handleInitializeDatabase(call: MethodCall, result: MethodChannel.Result) {
        val act = activity
        if (act == null) {
            result.error("NO_ACTIVITY", "Activity is not available.", null)
            return
        }

        val useDynamic = call.argument<Boolean>("useDynamicDb") ?: false
        val serverUrl = call.argument<String>("serverUrl") ?: ""
        val dbType = resolveDbType(call.argument<String>("dbType"))

        if (databaseReady.get()) {
            result.success(mapOf("success" to true, "message" to "Database already initialized"))
            return
        }

        val completion = object : InitializeDatabaseCompletion {
            override fun onProgressChanged(progress: Int) {
                mainHandler.post {
                    channel.invokeMethod("onDatabaseProgress", mapOf("progress" to progress))
                }
            }

            override fun onCompleted(status: Boolean, message: String?) {
                mainHandler.post {
                    if (status) {
                        databaseReady.set(true)
                        result.success(
                            mapOf(
                                "success" to true,
                                "message" to (message ?: "Database initialized"),
                            ),
                        )
                    } else {
                        result.error(
                            "DB_INIT_FAILED",
                            message ?: "Database initialization failed",
                            null,
                        )
                    }
                }
            }
        }

        if (useDynamic) {
            DataBaseDownloading.initializeDynamicDb(act, completion, serverUrl)
        } else {
            DataBaseDownloading.initializePreProcessedDb(act, dbType, completion, serverUrl)
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun handleGetWorkflows(result: MethodChannel.Result) {
        try {
            val workflows = iPassSDKManger.getWorkFlows()
            val list = workflows.map { hashMap ->
                hashMap.entries.associate { it.key to it.value }
            }
            result.success(list)
        } catch (e: Exception) {
            result.error("WORKFLOWS_ERROR", e.message, null)
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun handleStartKycVerification(call: MethodCall, result: MethodChannel.Result) {
        val act = activity
        if (act == null) {
            result.error("NO_ACTIVITY", "Activity is not available.", null)
            return
        }

        val email = call.argument<String>("email")
        val password = call.argument<String>("password")
        val appToken = call.argument<String>("appToken")
        val workflowId = call.argument<String>("workflowId")
        val socialMediaEmail = call.argument<String>("socialMediaEmail") ?: ""
        val phoneNumber = call.argument<String>("phoneNumber") ?: ""
        val enableHologram = call.argument<Boolean>("enableHologram") ?: false
        val skipDbInit = call.argument<Boolean>("skipDatabaseInit") ?: false
        val useDynamicDb = call.argument<Boolean>("useDynamicDb") ?: false
        val serverUrl = call.argument<String>("serverUrl") ?: ""
        val dbType = resolveDbType(call.argument<String>("dbType"))

        if (email.isNullOrBlank() || password.isNullOrBlank() || appToken.isNullOrBlank()) {
            result.error("INVALID_ARGS", "email, password, and appToken are required.", null)
            return
        }
        if (workflowId.isNullOrBlank()) {
            result.error("INVALID_ARGS", "workflowId is required.", null)
            return
        }

        configProperties.needHologramDetection(enableHologram)

        fun beginFlow() {
            val runVerification = {
                executeKycVerification(
                    act = act,
                    result = result,
                    email = email,
                    password = password,
                    appToken = appToken,
                    workflowId = workflowId,
                    socialMediaEmail = socialMediaEmail,
                    phoneNumber = phoneNumber,
                )
            }

            if (skipDbInit || databaseReady.get()) {
                runVerification()
            } else {
                initializeDatabaseThen(act, useDynamicDb, serverUrl, dbType, result, runVerification)
            }
        }

        requestKycPermissionsThen(act, result) { beginFlow() }
    }

    private fun requestKycPermissionsThen(
        act: Activity,
        result: MethodChannel.Result,
        onGranted: () -> Unit,
    ) {
        val missing = missingKycPermissions(act)
        if (missing.isEmpty()) {
            onGranted()
            return
        }

        pendingKycAction = onGranted
        pendingPermissionResult = result

        ActivityCompat.requestPermissions(
            act,
            missing,
            KYC_PERMISSION_REQUEST_CODE,
        )
    }

    private fun missingKycPermissions(act: Activity): Array<String> {
        return kycRuntimePermissions().filter { permission ->
            ContextCompat.checkSelfPermission(act, permission) !=
                PackageManager.PERMISSION_GRANTED
        }.toTypedArray()
    }

    private fun kycRuntimePermissions(): Array<String> {
        return arrayOf(
            Manifest.permission.CAMERA,
            Manifest.permission.RECORD_AUDIO,
        )
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun initializeDatabaseThen(
        act: Activity,
        useDynamicDb: Boolean,
        serverUrl: String,
        dbType: String,
        result: MethodChannel.Result,
        onReady: () -> Unit,
    ) {
        val completion = object : InitializeDatabaseCompletion {
            override fun onProgressChanged(progress: Int) {
                mainHandler.post {
                    channel.invokeMethod("onDatabaseProgress", mapOf("progress" to progress))
                }
            }

            override fun onCompleted(status: Boolean, message: String?) {
                if (!status) {
                    mainHandler.post {
                        result.error(
                            "DB_INIT_FAILED",
                            message ?: "Database initialization failed",
                            null,
                        )
                    }
                    return
                }
                databaseReady.set(true)
                onReady()
            }
        }

        if (useDynamicDb) {
            DataBaseDownloading.initializeDynamicDb(act, completion, serverUrl)
        } else {
            DataBaseDownloading.initializePreProcessedDb(act, dbType, completion, serverUrl)
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun executeKycVerification(
        act: Activity,
        result: MethodChannel.Result,
        email: String,
        password: String,
        appToken: String,
        workflowId: String,
        socialMediaEmail: String,
        phoneNumber: String,
    ) {
        val scannerHost = obtainScannerOverlay(act)

        iPassSDKManger.UserOnboardingProcess(
            act,
            email,
            password,
            object : ResultListener<AuthenticationResponse> {
                override fun onSuccess(response: AuthenticationResponse?) {
                    val userToken = response?.user?.token
                    if (userToken.isNullOrBlank()) {
                        clearScannerOverlay()
                        mainHandler.post {
                            result.error(
                                "AUTH_FAILED",
                                "Login succeeded but user token is empty.",
                                null,
                            )
                        }
                        return
                    }

                    iPassSDKManger.startScanningProcess(
                        act,
                        email,
                        userToken,
                        appToken,
                        socialMediaEmail,
                        phoneNumber,
                        workflowId,
                        scannerHost,
                    ) { status, message ->
                        if (!status) {
                            clearScannerOverlay()
                            mainHandler.post {
                                result.error("SCAN_FAILED", message, null)
                            }
                            return@startScanningProcess
                        }

                        iPassSDKManger.getDocumentScannerData(
                            act,
                            appToken,
                            object : ResultListener<TransactionDetailResponse> {
                                override fun onSuccess(
                                    scanResponse: TransactionDetailResponse?,
                                ) {
                                    clearScannerOverlay()
                                    mainHandler.post {
                                        if (scanResponse?.Apistatus == true) {
                                            result.success(
                                                mapOf(
                                                    "success" to true,
                                                    "apiStatus" to true,
                                                    "scanMessage" to message,
                                                    "data" to gson.toJson(scanResponse.data),
                                                    "rawResponse" to gson.toJson(scanResponse),
                                                ),
                                            )
                                        } else {
                                            result.error(
                                                "KYC_DATA_FAILED",
                                                "Document data API returned unsuccessful status.",
                                                gson.toJson(scanResponse),
                                            )
                                        }
                                    }
                                }

                                override fun onError(exception: String) {
                                    clearScannerOverlay()
                                    mainHandler.post {
                                        result.error("KYC_DATA_ERROR", exception, null)
                                    }
                                }
                            },
                        )
                    }
                }

                override fun onError(exception: String) {
                    clearScannerOverlay()
                    mainHandler.post {
                        result.error("AUTH_ERROR", exception, null)
                    }
                }
            },
        )
    }

    /**
     * Host scanner UI above Flutter surface so camera preview is visible after permission grant.
     */
    private fun obtainScannerOverlay(act: Activity): ViewGroup {
        clearScannerOverlay()
        val content = act.findViewById<ViewGroup>(android.R.id.content)
        val overlay = FrameLayout(act).apply {
            layoutParams = FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT,
            )
            setBackgroundColor(Color.TRANSPARENT)
            elevation = 1000f
            bringToFront()
        }
        content.addView(overlay)
        overlay.bringToFront()
        scannerOverlay = overlay
        return overlay
    }

    private fun clearScannerOverlay() {
        scannerOverlay?.let { overlay ->
            (overlay.parent as? ViewGroup)?.removeView(overlay)
        }
        scannerOverlay = null
    }

    private fun resolveDbType(dbType: String?): String {
        return when (dbType?.uppercase()) {
            "BASIC_JORDAN" -> DatabaseType.BASIC_JORDAN
            "FULL_AUTH_JORDAN" -> DatabaseType.FULL_AUTH_JORDAN
            else -> DatabaseType.FULL_DB
        }
    }

    companion object {
        const val CHANNEL_NAME = "com.baghdadbullion.bbhtrader/ipass_kyc"
        private const val KYC_PERMISSION_REQUEST_CODE = 0x4950 // "IP"
    }
}
