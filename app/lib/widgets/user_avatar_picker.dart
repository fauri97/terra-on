import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// TerraON — UserAvatarPicker
///
/// Widget reutilizável para exibir e alterar a foto do usuário.
/// Não acessa câmera/galeria diretamente por conta própria: por padrão,
/// a página/controlador deve fornecer os callbacks [onPick] e [onRemove].
///
/// Uso típico (modo simples, compatível com seu código atual):
///   UserAvatarPicker(
///     bytes: controller.avatarBytes,
///     onPick: controller.pickAvatar,      // controller decide a fonte
///     onRemove: controller.removeAvatar,
///   )
///
/// Uso com escolha de fonte dentro do widget:
///   UserAvatarPicker(
///     bytes: controller.avatarBytes,
///     onPick: () {}, // pode deixar vazio
///     onRemove: controller.removeAvatar,
///     onPickFromSource: (src) => controller.pickAvatar(src),
///   )
class UserAvatarPicker extends StatelessWidget {
  final Uint8List? bytes;

  /// Callback simples (compatibilidade com implementação atual).
  final VoidCallback onPick;

  /// Callback para remover a foto.
  final VoidCallback onRemove;

  /// (Opcional) Se fornecido, o widget abre um bottom sheet e chama
  /// este callback com a fonte escolhida (câmera/galeria).
  final Future<void> Function(ImageSource source)? onPickFromSource;

  final double radius;
  final String? label;

  const UserAvatarPicker({
    super.key,
    required this.bytes,
    required this.onPick,
    required this.onRemove,
    this.onPickFromSource,
    this.radius = 44,
    this.label,
  });

  Future<void> _handlePick(BuildContext context) async {
    if (onPickFromSource == null) {
      // Modo simples: delega para o callback existente
      onPick();
      return;
    }

    // Mostra as opções de origem dentro do próprio widget
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tirar foto (câmera)'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Escolher da galeria'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      await onPickFromSource!(source);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: scheme.primaryContainer,
          backgroundImage: bytes != null ? MemoryImage(bytes!) : null,
          child: bytes == null
              ? Icon(Icons.person, size: radius, color: scheme.onPrimaryContainer)
              : null,
        ),
        if (label != null) ...[
          const SizedBox(height: 8),
          Text(label!, style: text.bodyMedium),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () => _handlePick(context),
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Adicionar foto'),
            ),
            TextButton.icon(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remover'),
            ),
          ],
        ),
      ],
    );
  }
}
