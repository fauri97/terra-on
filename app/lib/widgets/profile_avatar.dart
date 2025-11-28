import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? base64Image;
  final double size;
  final Color? backgroundColor;

  const ProfileAvatar({
    super.key,
    this.base64Image,
    this.size = 36,
    this.backgroundColor,
  });

  Uint8List? _decodeBase64(String? b64) {
    if (b64 == null || b64.isEmpty) return null;
    try {
      var raw = b64.contains(',') ? b64.split(',').last : b64;
      raw = raw.replaceAll(RegExp(r'\s+'), ''); // remove espaços e quebras
      final mod = raw.length % 4;
      if (mod == 2)
        raw = '$raw==';
      else if (mod == 3)
        raw = '$raw=';
      else if (mod == 1)
        return null; // inválido
      return base64Decode(raw);
    } catch (e) {
      debugPrint('Falha ao decodificar imagem de perfil: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _decodeBase64(base64Image);
    final cs = Theme.of(context).colorScheme;

    return CircleAvatar(
      radius: size / 1.5,
      backgroundColor: backgroundColor ?? cs.primaryContainer,
      backgroundImage: (bytes != null) ? MemoryImage(bytes) : null,
      child: (bytes == null)
          ? Icon(Icons.person, size: size * 0.6, color: cs.onPrimaryContainer)
          : null,
    );
  }
}
