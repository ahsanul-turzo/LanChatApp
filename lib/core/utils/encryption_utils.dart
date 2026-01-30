import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionUtils {
  static String generateHash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static String generateMessageId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch;
    return generateHash('$timestamp-$random').substring(0, 16);
  }

  static encrypt.Encrypter? _encrypter;
  static encrypt.IV? _iv;

  static void initEncryption(String keyString) {
    final key = encrypt.Key.fromUtf8(keyString.padRight(32, '0').substring(0, 32));
    _iv = encrypt.IV.fromLength(16);
    _encrypter = encrypt.Encrypter(encrypt.AES(key));
  }

  static String? encryptMessage(String plainText) {
    if (_encrypter == null || _iv == null) return null;
    try {
      final encrypted = _encrypter!.encrypt(plainText, iv: _iv!);
      return encrypted.base64;
    } catch (e) {
      return null;
    }
  }

  static String? decryptMessage(String encryptedText) {
    if (_encrypter == null || _iv == null) return null;
    try {
      final decrypted = _encrypter!.decrypt64(encryptedText, iv: _iv!);
      return decrypted;
    } catch (e) {
      return null;
    }
  }

  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
