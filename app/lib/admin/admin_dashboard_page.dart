import 'package:flutter/material.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_footer.dart';

/// TerraON — AdminDashboardPage
///
/// Painel administrativo simples (mock).
/// Mostra contadores e atalhos para futuras telas administrativas.
/// Nenhuma lógica real por enquanto — apenas layout base.

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final mockCards = [
      _DashboardCardData(
        title: 'Abertas',
        icon: Icons.warning_amber_rounded,
        color: scheme.primaryContainer,
      ),
      _DashboardCardData(
        title: 'Em triagem',
        icon: Icons.assignment_turned_in_outlined,
        color: scheme.secondaryContainer,
      ),
      _DashboardCardData(
        title: 'Em andamento',
        icon: Icons.build_circle_outlined,
        color: scheme.tertiaryContainer,
      ),
      _DashboardCardData(
        title: 'Resolvidas',
        icon: Icons.check_circle_outline,
        color: scheme.surfaceTint.withOpacity(0.15),
      ),
    ];

    return Scaffold(
      appBar: const AppNavbar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Painel Administrativo',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: mockCards
                      .map((c) => _DashboardCard(data: c))
                      .toList(growable: false),
                ),
                const SizedBox(height: 32),
                Text(
                  'Ações rápidas',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Lista de denúncias em breve.'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.list_alt_outlined),
                      label: const Text('Lista de denúncias'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mapa administrativo em breve.'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Mapa'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Relatórios em breve.')),
                        );
                      },
                      icon: const Icon(Icons.bar_chart_outlined),
                      label: const Text('Relatórios'),
                    ),
                  ],
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

class _DashboardCardData {
  final String title;
  final IconData icon;
  final Color color;

  _DashboardCardData({
    required this.title,
    required this.icon,
    required this.color,
  });
}

class _DashboardCard extends StatelessWidget {
  final _DashboardCardData data;
  const _DashboardCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 180,
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: data.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(data.icon, size: 36, color: scheme.onPrimaryContainer),
          const SizedBox(height: 8),
          Text(
            data.title,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '0',
            style: textTheme.headlineSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
