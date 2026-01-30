import 'dart:convert';
import 'dart:typed_data';

import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

class FileUtils {
  static String getFileExtension(String filename) {
    return path.extension(filename).toLowerCase();
  }

  static String getFileName(String filePath) {
    return path.basename(filePath);
  }

  static String getMimeType(String filename) {
    return lookupMimeType(filename) ?? 'application/octet-stream';
  }

  static bool isImage(String filename) {
    final mimeType = getMimeType(filename);
    return mimeType.startsWith('image/');
  }

  static bool isVideo(String filename) {
    final mimeType = getMimeType(filename);
    return mimeType.startsWith('video/');
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  static String base64Encode(Uint8List bytes) {
    return base64.encode(bytes);
  }

  static Uint8List base64Decode(String base64String) {
    return base64.decode(base64String);
  }

  static String sanitizeFileName(String filename) {
    return filename.replaceAll(RegExp(r'[^\w\s.-]'), '_');
  }
}
