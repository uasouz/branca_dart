library branca_dart;

import 'dart:typed_data';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:base_x/base_x.dart';

import 'exceptions.dart';

const VERSION = 0xBA;
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
    Uint8List header = Uint8List.fromList([VERSION, ...v, ...nonce]);

    var ciphertext = Sodium.cryptoAeadXchacha20poly1305IetfEncrypt(
        Uint8List.fromList(payload.codeUnits), header, null, nonce, this.key);

    Uint8List binary = Uint8List.fromList([...header, ...ciphertext]);

    return base62.encode(binary);
  }

  String decode(String data, {int ttl}) {
    if (data.length < 62) {
      throw InvalidLengthException();
    }

    Uint8List binary = base62.decode(data);
    Uint8List header = binary.sublist(0, HEADER_BYTES);
    Uint8List ciphertext = binary.sublist(HEADER_BYTES, binary.length);

    int version = binary[0];

    if (version != VERSION) {
      throw VersionException();
    }

    int timestamp =
        ByteData.sublistView(header.sublist(1, 5)).getInt32(0, Endian.big);
    Uint8List nonce = header.sublist(5, HEADER_BYTES);

    var payload = Sodium.cryptoAeadXchacha20poly1305IetfDecrypt(
        null, ciphertext, header, nonce, this.key);

    if (ttl != null) {
      int future = timestamp + ttl;
      int now = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
      if (future < now) {
        throw TokenExpiredException();
      }
    }

    return String.fromCharCodes(payload);
  }
}
