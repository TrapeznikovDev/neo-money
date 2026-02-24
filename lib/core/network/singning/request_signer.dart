import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

abstract class RequestSigner {
  String reqTimeUtc(DateTime now);
  int timestampSeconds(DateTime now);

  String authHash({required String reqTime, required int timestamp});

  Map<String, dynamic> buildSignatureHeaders({
    required DateTime now,
    required String version,
  });
}

class Md5RequestSigner implements RequestSigner {
  final String secretKey;

  Md5RequestSigner({required this.secretKey});

  @override
  String reqTimeUtc(DateTime now) {
    return DateFormat('yyyy-MM-dd-HH-mm').format(now.toUtc());
  }

  @override
  int timestampSeconds(DateTime now) => now.millisecondsSinceEpoch ~/ 1000;

  String _saltHash({required String reqTime}) => _md5('$secretKey$reqTime');

  @override
  String authHash({required String reqTime, required int timestamp}) {
    return _md5('${_saltHash(reqTime: reqTime)}$timestamp');
  }

  @override
  Map<String, dynamic> buildSignatureHeaders({
    required DateTime now,
    required String version,
  }) {
    final reqTime = reqTimeUtc(now);
    final ts = timestampSeconds(now);

    return <String, dynamic>{
      'req-time': reqTime,
      'timestamp': ts,
      'version': version,
      'auth-hash': authHash(reqTime: reqTime, timestamp: ts),
      'site-id': 'neomani'
    };
  }

  String _md5(String input) => md5.convert(utf8.encode(input)).toString();
}