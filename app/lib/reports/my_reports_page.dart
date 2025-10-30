import 'package:flutter/material.dart';
import '../widgets/app_navbar.dart';
import '../widgets/app_footer.dart';
import '../services/service_locator.dart';
import '../services/report_service.dart';

/// TerraON — MyReportsPage
///
/// Lista de denúncias feitas pelo cidadão logado.
/// Nesta fase usa o ReportService (local → lista vazia).
/// Exibe estados de carregamento, vazio e erro.
/// Responsivo (web + mobile) e com pull-to-refresh.
class MyReportsPage extends StatefulWidget {
  const MyReportsPage({super.key});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  bool _loading = false;
  List<ReportSummary> _items = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _items = [];
    });

    try {
      // Se não estiver logado, apenas mostra vazio com aviso
      if (!authService.isLoggedIn) {
        setState(() {
          _items = [];
          _loading = false;
        });
        return;
      }

      final data = await reportService.getMyReports();
      setState(() {
        _items = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Não foi possível carregar suas denúncias.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const AppNavbar(),
      body: RefreshIndicator(
        onRefresh: _load,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Minhas denúncias',
                    style: text.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Estados: carregando / erro / vazio / lista
                  if (_loading)
                    const Expanded(child: Center(child: CircularProgressIndicator()))
                  else if (_error != null)
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.error_outline,
                        headline: 'Ocorreu um erro',
                        message: _error!,
                        scheme: scheme,
                        text: text,
                        actions: [
                          FilledButton.icon(
                            onPressed: _load,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    )
                  else if (_items.isEmpty)
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.inbox_outlined,
                        headline: authService.isLoggedIn
                            ? 'Você ainda não fez denúncias'
                            : 'É preciso entrar para ver suas denúncias',
                        message: authService.isLoggedIn
                            ? 'Quando você registrar uma denúncia, ela aparecerá aqui.'
                            : 'Acesse o menu do perfil e faça login para continuar.',
                        scheme: scheme,
                        text: text,
                        actions: [
                          if (authService.isLoggedIn)
                            FilledButton.icon(
                              onPressed: () => Navigator.pushNamed(context, '/new-report'),
                              icon: const Icon(Icons.add),
                              label: const Text('Nova denúncia'),
                            )
                          else
                            FilledButton.icon(
                              onPressed: () => Navigator.pushNamed(context, '/login-user'),
                              icon: const Icon(Icons.login),
                              label: const Text('Entrar'),
                            ),
                        ],
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) => _ReportTile(item: _items[i]),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({required this.item});
  final ReportSummary item;

  // status é enum (ReportStatus) → usamos .name para exibição e cor
  Color _statusColor(ReportStatus status, ColorScheme scheme) {
    final s = status.name.toLowerCase().replaceAll('_', ' ');
    switch (s) {
      case 'aberta':
        return scheme.tertiary;
      case 'em andamento':
        return scheme.primary;
      case 'resolvida':
        return scheme.secondary;
      default:
        return scheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        leading: const Icon(Icons.report_outlined),
        title: Text(item.title, style: text.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              '${item.category} • ${item.city}${item.district != null ? ' - ${item.district}' : ''}',
              style: text.bodyMedium,
            ),
            const SizedBox(height: 2),
            Text(
              // enum → exibir o nome
              item.status.name,
              style: text.bodySmall?.copyWith(
                color: _statusColor(item.status, scheme),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        onTap: () {
          // Futuro: Navigator.pushNamed(context, '/report-detail', arguments: item.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Detalhes da denúncia — em breve.')),
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.headline,
    required this.message,
    required this.scheme,
    required this.text,
    this.actions,
  });

  final IconData icon;
  final String headline;
  final String message;
  final ColorScheme scheme;
  final TextTheme text;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        // cartão centralizado e responsivo
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withOpacity(0.25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48),
              const SizedBox(height: 12),
              Text(headline, style: text.titleMedium, textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text(
                message,
                style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              if (actions != null) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: actions!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
