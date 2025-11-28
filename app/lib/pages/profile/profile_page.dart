import 'dart:convert';
import 'dart:typed_data';

import 'package:app/widgets/app_navbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/service_locator.dart'; // userService, tokenStore

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  bool _saving = false;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _ufCtrl = TextEditingController();

  String? _base64img;
  Uint8List? _imgBytes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // --- helpers de imagem ---
  Uint8List? _decodeBase64(String? b64) {
    if (b64 == null || b64.isEmpty) return null;
    try {
      final regex = RegExp(r'^data:[\w/\-\.]+;base64,');
      final clean = b64.replaceAll(regex, '');
      return base64Decode(clean);
    } catch (_) {
      return null;
    }
  }

  void _setImageFromBase64(String? b64) {
    _base64img = b64;
    _imgBytes = _decodeBase64(b64);
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      imageQuality: 80, // leve compressão
      maxWidth: 1024,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    setState(() {
      _imgBytes = bytes;
      _base64img =
          'data:image/${file.path.split('.').last};base64,${base64Encode(bytes)}';
    });
  }

  // --- load / save ---
  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await userService.getMyProfile();
      if (data != null) {
        _nameCtrl.text = data['name'] ?? '';
        _emailCtrl.text = data['email'] ?? '';
        _cityCtrl.text = data['city'] ?? '';
        _ufCtrl.text = data['state'] ?? '';
        _setImageFromBase64(data['base64ProfileImage']);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar perfil: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final id = tokenStore.userId;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sessão inválida. Faça login novamente.')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final ok = await userService.updateProfile(
      id: id,
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      uf: _ufCtrl.text.trim(),
      base64Image: _base64img,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Salvo com sucesso!' : 'Erro ao salvar')),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _cityCtrl.dispose();
    _ufCtrl.dispose();
    super.dispose();
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppNavbar(),
      body: Stack(
        children: [
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 56,
                          backgroundColor: cs.surfaceVariant,
                          backgroundImage: (_imgBytes != null)
                              ? MemoryImage(_imgBytes!)
                              : null,
                          child: (_imgBytes == null)
                              ? Text(
                                  _initials(_nameCtrl.text),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Material(
                            color: cs.primary,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: _showPickImageSheet,
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Foto de perfil',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 24),

                  // Card com formulário
                  Card(
                    elevation: 0,
                    color: cs.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: cs.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Nome',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              textInputAction: TextInputAction.next,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Informe seu nome'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _emailCtrl,
                              decoration: const InputDecoration(
                                labelText: 'E-mail',
                                prefixIcon: Icon(Icons.alternate_email),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              enabled: false, // normalmente não se edita aqui
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _ufCtrl,
                              decoration: const InputDecoration(
                                labelText: 'UF',
                                prefixIcon: Icon(Icons.place_outlined),
                              ),
                              textCapitalization: TextCapitalization.characters,
                              maxLength: 2,
                              buildCounter:
                                  (
                                    _, {
                                    required currentLength,
                                    maxLength,
                                    required isFocused,
                                  }) => const SizedBox.shrink(),
                              validator: (v) {
                                final s = (v ?? '').trim().toUpperCase();
                                if (s.isEmpty) return null; // opcional
                                if (s.length != 2) return 'UF inválida';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _cityCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Cidade',
                                prefixIcon: Icon(Icons.location_city_outlined),
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: _load,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Recarregar'),
                                ),
                                const SizedBox(width: 8),
                                FilledButton.icon(
                                  onPressed: _saving ? null : _save,
                                  icon: const Icon(Icons.save_outlined),
                                  label: const Text('Salvar alterações'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // overlay de salvando
          if (_saving)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withOpacity(0.1),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  void _showPickImageSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Escolher da galeria'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Tirar foto'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                if (_imgBytes != null)
                  ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: const Text('Remover foto'),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      setState(() {
                        _imgBytes = null;
                        _base64img = null;
                      });
                    },
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '👤';
    final first = parts.first.substring(0, 1);
    final last = parts.length > 1 ? parts.last.substring(0, 1) : '';
    return (first + last).toUpperCase();
  }
}
