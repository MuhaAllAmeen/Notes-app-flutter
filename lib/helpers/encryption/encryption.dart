import 'dart:convert';

import 'package:encrypt/encrypt.dart';


class EncryptData{

  static Encrypted? encrypted;
  static late String decrypted;
  static final key = Key.fromUtf8('my32lengthsupersecretnooneknows1');

  static final b64key = Key.fromUtf8(base64Url.encode(key.bytes).substring(0,32));
  static final fernet = Fernet(b64key);
  static final encrypter = Encrypter(fernet);

  
  static String encryptAES(String plainText){
    if (plainText!=''){
      encrypted = encrypter.encrypt(plainText);
      return encrypted!.base64;
    }
    return '';
    
 }

  static String decryptAES(String encryptedText){
    if (encryptedText!=''){
      decrypted = encrypter.decrypt64(encryptedText);
      return decrypted;
    }
    return '';
    
  }
}