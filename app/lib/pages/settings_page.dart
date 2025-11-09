import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: scheme.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Geral',
            style: text.titleMedium?.copyWith(color: scheme.primary),
          ),
          const SizedBox(height: 8),

          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Editar perfil'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/profile'),
          ),

          const Divider(height: 32),

          Text(
            'Legal',
            style: text.titleMedium?.copyWith(color: scheme.primary),
          ),
          const SizedBox(height: 8),

          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Termos de Uso'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/terms'),
          ),
        ],
      ),
    );
  }
}
