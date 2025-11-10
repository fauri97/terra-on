import 'package:flutter/material.dart';
import '../../services/service_locator.dart'; // pra acessar userService
import '../../core/tokens/token_store.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _loading = false;

  // controllers fixos
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _ufCtrl = TextEditingController();

  String? _base64img;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await userService.getMyProfile();
    if (data != null) {
      _nameCtrl.text = data['name'] ?? '';
      _emailCtrl.text = data['email'] ?? '';
      _cityCtrl.text = data['city'] ?? '';
      _ufCtrl.text = data['state'] ?? '';
      _base64img = data['base64ProfileImage'];
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final id = tokenStore.userId;
    if (id == null) return;

    setState(() => _loading = true);

    final ok = await userService.updateProfile(
      id: id,
      name: _nameCtrl.text,
      email: _emailCtrl.text,
      city: _cityCtrl.text,
      uf: _ufCtrl.text,
      base64Image: _base64img,
    );

    setState(() => _loading = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Salvo com sucesso!' : 'Erro ao salvar'),
      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: 'Nome'),
                    controller: _nameCtrl,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(labelText: 'E-mail'),
                    controller: _emailCtrl,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Cidade'),
                    controller: _cityCtrl,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(labelText: 'UF'),
                    controller: _ufCtrl,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _save,
                    child: const Text('Salvar'),
                  ),
                ],
              ),
            ),
    );
  }
}
