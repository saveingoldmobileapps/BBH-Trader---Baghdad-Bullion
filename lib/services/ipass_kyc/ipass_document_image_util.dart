import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Prepares camera captures off the UI thread (resize + JPEG + base64).
class IpassDocumentImageUtil {
  IpassDocumentImageUtil._();

  static const int maxLongEdge = 1600;
  static const int jpegQuality = 82;

  static Future<String> encodeToBase64(File file) {
    return compute(_prepareInIsolate, file.path);
  }

  /// Writes raw or JPEG base64 from iPass into a temp file for multipart upload.
  static Future<File> writeBase64ToTempFile({
    required String base64,
    required String fileNameStem,
    String? mimeType,
  }) async {
    final normalized = _stripDataUrlPrefix(base64.trim());
    if (normalized.isEmpty) {
      throw ArgumentError('Empty base64 payload');
    }

    final resolvedMime = mimeType ?? guessMimeFromBase64(normalized);
    final ext = extensionForMime(resolvedMime);
    final bytes = base64Decode(normalized);

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileNameStem.$ext');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static String guessMimeFromBase64(String base64) {
    if (base64.startsWith('/9j/') || base64.startsWith('data:image/jpeg')) {
      return 'image/jpeg';
    }
    if (base64.startsWith('iVBORw0KGgo') || base64.startsWith('data:image/png')) {
      return 'image/png';
    }
    return 'image/jpeg';
  }

  static String extensionForMime(String mime) {
    switch (mime) {
      case 'image/png':
        return 'png';
      case 'image/jpeg':
      case 'image/jpg':
        return 'jpg';
      default:
        return 'jpg';
    }
  }

  static String _stripDataUrlPrefix(String value) {
    final comma = value.indexOf(',');
    if (value.startsWith('data:') && comma >= 0) {
      return value.substring(comma + 1);
    }
    return value;
  }

  /// Must be top-level or static for [compute].
  static String _prepareInIsolate(String path) {
    final raw = File(path).readAsBytesSync();
    if (raw.isEmpty) return '';

    final decoded = img.decodeImage(raw);
    if (decoded == null) {
      return base64Encode(raw);
    }

    final longEdge = decoded.width > decoded.height
        ? decoded.width
        : decoded.height;
    img.Image output = decoded;
    if (longEdge > maxLongEdge) {
      output = img.copyResize(
        decoded,
        width: decoded.width >= decoded.height ? maxLongEdge : null,
        height: decoded.height > decoded.width ? maxLongEdge : null,
      );
    }

    final jpeg = img.encodeJpg(output, quality: jpegQuality);
    return base64Encode(jpeg);
  }
}
