import 'package:flutter/material.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_footer.dart';

/// TerraON — AboutPage
///
/// Página “Sobre o TerraON”
///
/// Mostra missão, equipe e contatos (mock).
/// Layout simples, responsivo e Material 3.

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const AppNavbar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sobre o TerraON',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'O TerraON é um aplicativo cívico e ambiental que conecta cidadãos, prefeituras e organizações para melhorar o espaço urbano e proteger o meio ambiente.',
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Text(
                  'Missão',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Facilitar o registro e a gestão de denúncias urbanas e ambientais, promovendo a transparência e o engajamento social.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Text(
                  'Equipe',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: const [
                    Chip(label: Text('Desenvolvimento')),
                    Chip(label: Text('Design & UX')),
                    Chip(label: Text('Administração Pública')),
                    Chip(label: Text('Cidadania e Sustentabilidade')),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Contato',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('contato@terraon.org'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Função de contato futura.'),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.web_outlined),
                  title: const Text('www.terraon.org'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Abrir site externo em breve.'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'Versão 1.0 (frontend Flutter)',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }
}
