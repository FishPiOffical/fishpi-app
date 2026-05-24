import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:fishpi/types/types.dart';

extension Utils on String {
  toMD5() {
    var content = const Utf8Encoder().convert(this);
    var digest = md5.convert(content);
    return hex.encode(digest.bytes);
  }
}

Metal analyzeMetalAttr(m) {
  if (m == null) throw 'metal is null';
  if (m['attr'] is! String) return Metal.from(m);
  var attr = m['attr'].split('&');
  m['attr'] = {"src": m['attr']};
  attr.forEach((a) => m['attr'][a.split('=')[0]] = a.split('=')[1]);
  return Metal.from(m);
}

MetalList toMetal(String sysMetal) {
  try {
    return List.from(json.decode(sysMetal)['list'] ?? [])
        .map(analyzeMetalAttr)
        .toList();
  } catch (error) {
    return [];
  }
}
