import 'package:encrypt/encrypt.dart';
import 'dart:convert';

class CryptoHelper {
  static const _secretKey = 'aXv92Lk01Zm48Tyz';
  static const _iv = 'c9P6u1GvTqR4Bn7f';

  static String encryptArticleId(String id, String title) {
    final key = Key.fromUtf8(_secretKey);
    final iv = IV.fromUtf8(_iv);

    final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));

    final combined = '$id-$title';
    final encrypted = encrypter.encrypt(combined, iv: iv);

    return encrypted.base64;
  }

  static String decryptArticleId(String encryptedText) {
    final key = Key.fromUtf8(_secretKey);
    final iv = IV.fromUtf8(_iv);

    final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));

    final decrypted = encrypter.decrypt64(encryptedText, iv: iv);

    return decrypted;
  }
}
