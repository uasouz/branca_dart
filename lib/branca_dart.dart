library branca_dart;

import 'dart:typed_data';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:base_x/base_x.dart';

const version = 0xBA;
const NONCE_BYTES = 24;
const HEADER_BYTES = 29;
const BASE62 = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

BaseXCodec base62 = BaseXCodec(BASE62);

Uint8List int32BigEndianBytes(int value) =>
    Uint8List(4)..buffer.asByteData().setInt32(0, value, Endian.big);

class Branca {
  Uint8List key;
  Uint8List nonce;

  Branca(String key) {
    Sodium.init();
    this.key = Uint8List.fromList(key.codeUnits);
  }

  String encode(String payload, {int timestamp}) {
    Uint8List nonce;

    if (this.nonce != null) {
      nonce = this.nonce;
    } else {
      nonce = Sodium.randombytesBuf(NONCE_BYTES);
    }

    if (timestamp == null) {
      timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    }
    var v = int32BigEndianBytes(timestamp);
    Uint8List header = Uint8List.fromList(
        [version, ...v, ...nonce]);

    var ciphertext = Sodium.cryptoAeadXchacha20poly1305IetfEncrypt(
        Uint8List.fromList(payload.codeUnits), header, null, nonce, this.key);

    Uint8List binary = Uint8List.fromList([...header, ...ciphertext]);

    return base62.encode(binary);
  }
}