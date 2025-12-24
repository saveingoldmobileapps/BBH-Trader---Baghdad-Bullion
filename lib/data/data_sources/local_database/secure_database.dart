import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SecureStorageService {
  // Singleton implementation to ensure only one instance exists
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  final _logger = Logger();

  // Factory constructor to return the singleton instance
  factory SecureStorageService() => _instance;

  // Private constructor for singleton pattern
  SecureStorageService._internal();

  // Getter for accessing the singleton instance
  static SecureStorageService get instance => _instance;

  // FlutterSecureStorage instance with platform-specific configurations
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences:
          true, // Use encrypted shared preferences on Android
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility
          .first_unlock, // Keychain accessibility setting for iOS
    ),
  );

  /// Writes a value to secure storage for the given key
  /// If value is null, it deletes the key instead
  /// Throws SecureStorageException on failure
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
  }) async {
    try {
      if (value == null) {
        await delete(key: key);
        return;
      }
      await _storage.write(
        key: key,
        value: value,
        iOptions: iOptions,
        aOptions: aOptions,
      );
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw SecureStorageException(
        'Failed to write secure storage for key: $key',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Reads a value from secure storage for the given key
  /// Returns null if key doesn't exist
  /// Throws SecureStorageException on failure
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
  }) async {
    try {
      return await _storage.read(
        key: key,
        iOptions: iOptions,
        aOptions: aOptions,
      );
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw SecureStorageException(
        'Failed to read secure storage for key: $key',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Deletes the value associated with the given key
  /// Throws SecureStorageException on failure
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
  }) async {
    try {
      await _storage.delete(
        key: key,
        iOptions: iOptions,
        aOptions: aOptions,
      );
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw SecureStorageException(
        'Failed to delete secure storage for key: $key',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Deletes all keys and values from secure storage
  /// Throws SecureStorageException on failure
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
  }) async {
    try {
      await _storage.deleteAll(
        iOptions: iOptions,
        aOptions: aOptions,
      );
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw SecureStorageException(
        'Failed to clear secure storage',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Checks if a key exists in secure storage
  Future<bool> containsKey({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
  }) async {
    try {
      return await _storage.containsKey(
        key: key,
        iOptions: iOptions,
        aOptions: aOptions,
      );
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw SecureStorageException(
        'Failed to check key existence: $key',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Reads all key-value pairs from secure storage
  Future<Map<String, String>> readAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
  }) async {
    try {
      return await _storage.readAll(
        iOptions: iOptions,
        aOptions: aOptions,
      );
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw SecureStorageException(
        'Failed to read all secure storage',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Retrieves the refresh token from secure storage
  Future<String?> getRefreshToken({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
  }) async {
    try {
      return await _storage.read(
        key: Strings.userRefreshToken,
        iOptions: iOptions,
        aOptions: aOptions,
      );
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw SecureStorageException(
        'Failed to read secure storage for key: ${Strings.userRefreshToken}',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Saves the refresh token to secure storage
  Future<void> saveUserRefreshToken({
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
  }) async {
    try {
      if (value == null) {
        await delete(
          key: Strings.userRefreshToken,
        );
        return;
      }
      await _storage.write(
        key: Strings.userRefreshToken,
        value: value,
        iOptions: iOptions,
        aOptions: aOptions,
      );
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw SecureStorageException(
        'Failed to write secure storage for key: ${Strings.userRefreshToken}',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Stores the face recognition enable status in secure storage
  Future<void> storeFaceEnable({
    required bool isEnable,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
  }) async {
    try {
      await _storage.write(
        key: Strings.isFaceEnable,
        value: isEnable.toString(),
        iOptions: iOptions,
        aOptions: aOptions,
      );
      _logger.i("faceIdStored: $isEnable");
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      _logger.e("errorFaceEnable: $e", error: e, stackTrace: stackTrace);
      throw SecureStorageException(
        'Failed to store face enable status',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Retrieves the face recognition enable status from secure storage
  Future<bool?> getFaceEnable({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
  }) async {
    try {
      final result = await _storage.read(
        key: Strings.isFaceEnable,
        iOptions: iOptions,
        aOptions: aOptions,
      );
      return result != null ? result.toLowerCase() == 'true' : null;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      _logger.e("errorGetFaceEnable: $e", error: e, stackTrace: stackTrace);
      throw SecureStorageException(
        'Failed to retrieve face enable status',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Stores the fingerprint enable status in secure storage
  Future<void> storeFingerEnable({
    required bool isEnable,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
  }) async {
    try {
      await _storage.write(
        key: Strings.isFingerEnable,
        value: isEnable.toString(),
        iOptions: iOptions,
        aOptions: aOptions,
      );
      _logger.i("fingerIdStored: $isEnable");
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      _logger.e("errorFingerEnable: $e", error: e, stackTrace: stackTrace);
      throw SecureStorageException(
        'Failed to store fingerprint enable status',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Retrieves the fingerprint enable status from secure storage
  Future<bool?> getFingerEnable({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
  }) async {
    try {
      final result = await _storage.read(
        key: Strings.isFingerEnable,
        iOptions: iOptions,
        aOptions: aOptions,
      );
      if (result == null) return null;
      return result.toLowerCase() == 'true';
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      _logger.e("errorGetFingerEnable: $e", error: e, stackTrace: stackTrace);
      throw SecureStorageException(
        'Failed to retrieve fingerprint enable status',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}

/// Custom exception class for secure storage operations
class SecureStorageException implements Exception {
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  SecureStorageException(this.message, {this.error, this.stackTrace});

  @override
  String toString() =>
      'SecureStorageException: $message'
      '${error != null ? '\nError: $error' : ''}'
      '${stackTrace != null ? '\nStackTrace: $stackTrace' : ''}';
}
