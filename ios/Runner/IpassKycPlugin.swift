import AVFoundation
import Flutter
import UIKit

/// Flutter method channel bridge for iPass KYC SDK (iOS).
/// Add Swift Package: https://github.com/iPass-MENA/iPass2.0NativeiOS
/// @see https://devdocs.ipass-mena.com/sdk-version-2.html
#if canImport(iPass2_0NativeiOS)
import iPass2_0NativeiOS

private func parseWorkflowId(_ value: Any?) -> Int? {
  if let intVal = value as? Int { return intVal }
  if let strVal = value as? String { return Int(strVal) }
  return nil
}

private func resolveDbSource(_ dbType: String?) -> DataBaseDownloading.availableDataSources {
  switch dbType?.uppercased() {
  case "BASIC_JORDAN":
    return .basicJordan
  case "FULL_AUTH_JORDAN":
    return .fullAuthJordan
  default:
    return .fullDb
  }
}

/// New iPass SDK reports readiness via status string (e.g. "Start Now"), not Bool.
private func databaseInitSucceeded(status: String, error: String) -> Bool {
  if !error.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
    return false
  }
  let normalized = status.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
  return normalized == "start now" || normalized == "startnow"
}

private func reportDatabaseProgress(_ progressText: String, channel: FlutterMethodChannel?) {
  let numeric = progressText.filter { $0.isNumber || $0 == "." }
  guard let value = Double(numeric) else { return }
  channel?.invokeMethod(
    "onDatabaseProgress",
    arguments: ["progress": Int(value.rounded())]
  )
}

private func topViewController(base: UIViewController? = nil) -> UIViewController? {
  let base = base ?? UIApplication.shared.connectedScenes
    .compactMap { $0 as? UIWindowScene }
    .flatMap { $0.windows }
    .first { $0.isKeyWindow }?
    .rootViewController

  if let nav = base as? UINavigationController {
    return topViewController(base: nav.visibleViewController)
  }
  if let tab = base as? UITabBarController {
    return topViewController(base: tab.selectedViewController)
  }
  if let presented = base?.presentedViewController {
    return topViewController(base: presented)
  }
  return base
}

final class IpassKycPlugin: NSObject, FlutterPlugin, iPassSDKManagerDelegate {
  private var channel: FlutterMethodChannel?
  private var pendingResult: FlutterResult?
  private var appToken: String = ""
  private var databaseReady = false

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.baghdadbullion.bbhtrader/ipass_kyc",
      binaryMessenger: registrar.messenger()
    )
    let instance = IpassKycPlugin()
    instance.channel = channel
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "checkPermissions":
      checkPermissions(result: result)
    case "initializeDatabase":
      guard let args = call.arguments as? [String: Any] else {
        result(FlutterError(code: "INVALID_ARGS", message: "Arguments required", details: nil))
        return
      }
      initializeDatabase(args: args, result: result)
    case "getWorkflows":
      let workflows = iPassSDKManger.getWorkFlows()
      result(workflows)
    case "startKycVerification":
      guard let args = call.arguments as? [String: Any] else {
        result(FlutterError(code: "INVALID_ARGS", message: "Arguments required", details: nil))
        return
      }
      startKycVerification(args: args, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func checkPermissions(result: @escaping FlutterResult) {
    let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
    let micGranted = AVAudioSession.sharedInstance().recordPermission == .granted
    let cameraGranted = cameraStatus == .authorized
    var missing: [String] = []
    if !cameraGranted { missing.append("camera") }
    if !micGranted { missing.append("microphone") }

    result([
      "granted": missing.isEmpty,
      "missing": missing,
    ])
  }

  private func requestCameraAndMicrophone(
    completion: @escaping (Bool, String?) -> Void
  ) {
    let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)

    func requestMicrophone(then: @escaping (Bool) -> Void) {
      switch AVAudioSession.sharedInstance().recordPermission {
      case .granted:
        then(true)
      case .denied:
        then(false)
      case .undetermined:
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
          DispatchQueue.main.async { then(granted) }
        }
      @unknown default:
        then(false)
      }
    }

    switch cameraStatus {
    case .authorized:
      requestMicrophone { micOk in
        completion(micOk, micOk ? nil : "Microphone permission is required for KYC.")
      }
    case .denied, .restricted:
      completion(false, "Camera permission is required. Enable it in Settings > Baghdad Bullion > Camera.")
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: .video) { videoGranted in
        guard videoGranted else {
          DispatchQueue.main.async {
            completion(false, "Camera permission is required for KYC.")
          }
          return
        }
        requestMicrophone { micOk in
          completion(micOk, micOk ? nil : "Microphone permission is required for KYC.")
        }
      }
    @unknown default:
      completion(false, "Camera permission is unavailable.")
    }
  }

  private func initializeDatabase(args: [String: Any], result: @escaping FlutterResult) {
    if databaseReady {
      result(["success": true, "message": "Database already initialized"])
      return
    }

    let enableHologram = args["enableHologram"] as? Bool ?? false
    configProperties.needHologramDetection(value: enableHologram)

    runDatabaseInitialization(
      args: args,
      onSuccess: { [weak self] message in
        self?.databaseReady = true
        result(["success": true, "message": message])
      },
      onFailure: { message in
        result(
          FlutterError(
            code: "DB_INIT_FAILED",
            message: message,
            details: nil
          )
        )
      }
    )
  }

  private func runDatabaseInitialization(
    args: [String: Any],
    onSuccess: @escaping (String) -> Void,
    onFailure: @escaping (String) -> Void
  ) {
    let useDynamicDb = args["useDynamicDb"] as? Bool ?? false
    let serverUrl = args["serverUrl"] as? String ?? ""
    let dbType = resolveDbSource(args["dbType"] as? String)

    if useDynamicDb {
      DataBaseDownloading.initializeDynamicDb(serverUrl: serverUrl) {
        [weak self] progress, status, error in
        DispatchQueue.main.async {
          if !progress.isEmpty {
            reportDatabaseProgress(progress, channel: self?.channel)
          }
          if databaseInitSucceeded(status: status, error: error) {
            onSuccess(status.isEmpty ? "Database initialized" : status)
          } else if !error.isEmpty {
            onFailure(error)
          }
        }
      }
    } else {
      DataBaseDownloading.initializePreProcessedDb(
        serverUrl: serverUrl,
        dbType: dbType
      ) { [weak self] status, error in
        DispatchQueue.main.async {
          if databaseInitSucceeded(status: status, error: error) {
            self?.channel?.invokeMethod(
              "onDatabaseProgress",
              arguments: ["progress": 100]
            )
            onSuccess(status.isEmpty ? "Database initialized" : status)
          } else if !error.isEmpty {
            onFailure(error)
          }
        }
      }
    }
  }

  private func startKycVerification(args: [String: Any], result: @escaping FlutterResult) {
    guard
      let email = args["email"] as? String, !email.isEmpty,
      let password = args["password"] as? String, !password.isEmpty,
      let token = args["appToken"] as? String, !token.isEmpty,
      let workflowId = parseWorkflowId(args["workflowId"])
    else {
      result(
        FlutterError(
          code: "INVALID_ARGS",
          message: "email, password, appToken, and workflowId are required",
          details: nil
        )
      )
      return
    }

    let socialEmail = args["socialMediaEmail"] as? String ?? ""
    let phone = args["phoneNumber"] as? String ?? ""
    let enableHologram = args["enableHologram"] as? Bool ?? false
    let skipDb = args["skipDatabaseInit"] as? Bool ?? false
    let useDynamicDb = args["useDynamicDb"] as? Bool ?? false
    let serverUrl = args["serverUrl"] as? String ?? ""
    let dbType = args["dbType"] as? String

    appToken = token
    pendingResult = result
    configProperties.needHologramDetection(value: enableHologram)

    guard topViewController() != nil else {
      result(FlutterError(code: "NO_CONTROLLER", message: "No root view controller", details: nil))
      return
    }

    requestCameraAndMicrophone { [weak self] granted, message in
      guard let self = self else { return }
      guard granted else {
        result(
          FlutterError(
            code: "PERMISSION_DENIED",
            message: message ?? "Camera and microphone permissions are required.",
            details: nil
          )
        )
        return
      }

      if skipDb || self.databaseReady {
        self.loginAndScan(
          email: email,
          password: password,
          token: token,
          workflowId: workflowId,
          socialEmail: socialEmail,
          phone: phone,
          result: result
        )
        return
      }

      var dbArgs = args
      dbArgs["useDynamicDb"] = useDynamicDb
      dbArgs["serverUrl"] = serverUrl
      dbArgs["dbType"] = dbType

      self.runDatabaseInitialization(
        args: dbArgs,
        onSuccess: { [weak self] _ in
          guard let self = self else { return }
          self.databaseReady = true
          self.loginAndScan(
            email: email,
            password: password,
            token: token,
            workflowId: workflowId,
            socialEmail: socialEmail,
            phone: phone,
            result: result
          )
        },
        onFailure: { message in
          result(
            FlutterError(
              code: "DB_INIT_FAILED",
              message: message,
              details: nil
            )
          )
        }
      )
    }
  }

  private func loginAndScan(
    email: String,
    password: String,
    token: String,
    workflowId: Int,
    socialEmail: String,
    phone: String,
    result: @escaping FlutterResult
  ) {
    guard let controller = topViewController() else {
      result(FlutterError(code: "NO_CONTROLLER", message: "No root view controller", details: nil))
      return
    }

    iPassSDKManger.UserOnboardingProcess(email: email, password: password) { status, tokenString in
      DispatchQueue.main.async {
        guard status == true, let userToken = tokenString, !userToken.isEmpty else {
          result(
            FlutterError(
              code: "AUTH_ERROR",
              message: tokenString ?? "Authentication failed",
              details: nil
            )
          )
          return
        }

        iPassSDKManger.delegate = self
        Task { @MainActor in
          await iPassSDKManger.startScanningProcess(
            userEmail: email,
            flowId: workflowId,
            socialMediaEmail: socialEmail,
            phoneNumber: phone,
            controller: controller,
            userToken: userToken,
            appToken: token
          )
        }
      }
    }
  }

  func getScanCompletionResult(result scanResult: String, transactionId: String, error: String) {
    guard let flutterResult = pendingResult else { return }
    pendingResult = nil

    if !error.isEmpty {
      flutterResult(
        FlutterError(code: "SCAN_FAILED", message: error, details: nil)
      )
      return
    }

    flutterResult([
      "success": true,
      "apiStatus": true,
      "transactionId": transactionId,
      "data": scanResult,
      "rawResponse": scanResult,
    ])
  }
}

#else

/// Stub when iPass Swift package is not linked in Xcode.
final class IpassKycPlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.baghdadbullion.bbhtrader/ipass_kyc",
      binaryMessenger: registrar.messenger()
    )
    let instance = IpassKycPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result(
      FlutterError(
        code: "IPASS_NOT_LINKED",
        message: "Add iPass2.0NativeiOS via Xcode: File > Add Package Dependencies > https://github.com/iPass-MENA/iPass2.0NativeiOS",
        details: nil
      )
    )
  }
}

#endif