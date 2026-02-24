import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

class HashHeaders {
  HashHeaders({
    required String secretKey,
    required String appVersion,
  })  : _secretKey = secretKey,
        _appVersion = appVersion;

  final String _secretKey;
  final String _appVersion;

  Map<String, dynamic> build(DateTime dt) {
    final reqTime = DateFormat('yyyy-MM-dd-HH-mm').format(dt.toUtc());
    final timestamp = (dt.millisecondsSinceEpoch / 1000).floor();

    return {
      'req-time': reqTime,
      'timestamp': timestamp,
      'version': _appVersion,
      'auth-hash': _authHash(reqTime: reqTime, timestamp: timestamp),
    };
  }

  String _saltHash({required String reqTime}) => _md5("$_secretKey$reqTime");

  String _authHash({required String reqTime, required int timestamp}) {
    return _md5("${_saltHash(reqTime: reqTime)}$timestamp");
  }

  String _md5(String input) {
    final bytes = utf8.encode(input);
    return md5.convert(bytes).toString();
  }
}