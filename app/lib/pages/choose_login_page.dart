import 'package:flutter/material.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_footer.dart';

/// TerraON — ChooseLoginPage
///
/// Tela inicial que permite escolher o tipo de acesso:
/// - Pessoa Física (login comum)
/// - Instituição (admin)
/// - Visitante (sem login)
///
/// Rotas:
///   /login-user
///   /login-admin
///   /explore (visitante)
class ChooseLoginPage extends StatelessWidget {
  const ChooseLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const AppNavbar(showNewReportButton: false),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.public, color: scheme.primary, size: 72),
              const SizedBox(height: 16),
              Text(
                'Bem-vindo ao TerraON',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Cidadania e meio ambiente ao seu alcance.\nEscolha como deseja entrar:',
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Pessoa Física
              _buildButton(
                context,
                icon: Icons.person_outline,
                label: 'Entrar como Pessoa Física',
                onTap: () => Navigator.pushNamed(context, '/login-user'),
              ),
              const SizedBox(height: 16),

              // Instituição (Admin)
              _buildButton(
                context,
                icon: Icons.account_balance,
                label: 'Entrar como Instituição (Admin)',
                onTap: () => Navigator.pushNamed(context, '/login-admin'),
              ),
              const SizedBox(height: 16),

              // Visitante (SEM login!) -> apenas navega para Explorar
              _buildButton(
                context,
                icon: Icons.visibility,
                label: 'Entrar como Visitante',
                onTap: () => _enterAsGuest(context),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }

  /// Visitante: mostra um aviso e segue para /explore SEM efetuar login.
  /// Mantendo o usuário deslogado, a AppNavbar não exibirá “Nova denúncia”.
  Future<void> _enterAsGuest(BuildContext context) async {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Entrar como visitante'),
        content: Text(
          'No modo visitante, você poderá explorar denúncias públicas, '
          'mas não poderá criar, curtir ou comentar até fazer login ou cadastro.',
          style: text.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
            ),
            child: const Text('Continuar como visitante'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // ⚠️ Importante: sem autenticar aqui!
    // Apenas navega para a tela de exploração pública.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Entrando como visitante (sem login)...')),
    );
    Navigator.pushNamed(context, '/explore');
  }

  Widget _buildButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 320,
      child: FilledButton.icon(
        icon: Icon(icon, color: scheme.onPrimary),
        label: Text(label),
        onPressed: onTap,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
