import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/models/report_models.dart'; // contém InlineImage

class AvatarCircle extends StatelessWidget {
  final InlineImage? avatar; // <- mudou
  final double size;

  const AvatarCircle({super.key, required this.avatar, this.size = 36});

  Uint8List? _decode(InlineImage? img) {
    if (img == null) return null;
    final b64 = img.base64?.trim();
    if (b64 == null || b64.isEmpty) return null;
    try {
      return base64Decode(b64);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _decode(avatar);
    return CircleAvatar(
      radius: size / 2,
      backgroundImage: (bytes != null) ? MemoryImage(bytes) : null,
      child: (bytes == null) ? Icon(Icons.person, size: size * 0.6) : null,
    );
  }
}
