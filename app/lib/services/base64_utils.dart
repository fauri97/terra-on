import 'dart:convert';
import 'dart:typed_data';

Uint8List? tryDecodeBase64(String? input) {
  if (input == null) return null;

  var s = input.trim();

  final comma = s.indexOf(',');
  if (comma != -1 && s.substring(0, comma).toLowerCase().contains('base64')) {
    s = s.substring(comma + 1);
  }

  s = s.replaceAll(RegExp(r'\s+'), '');

  final mod = s.length % 4;
  if (mod == 1) {
    return null;
  } else if (mod > 0) {
    s = s.padRight(s.length + (4 - mod), '=');
  }

  try {
    return base64Decode(s);
  } catch (_) {
    return null;
  }
}
