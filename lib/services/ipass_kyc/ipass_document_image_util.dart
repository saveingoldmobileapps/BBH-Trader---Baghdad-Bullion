import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Prepares camera captures off the UI thread (resize + JPEG + base64).
class IpassDocumentImageUtil {
  IpassDocumentImageUtil._();

  static const int maxLongEdge = 1600;
  static const int jpegQuality = 82;

  static Future<String> encodeToBase64(File file) {
    return compute(_prepareInIsolate, file.path);
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
