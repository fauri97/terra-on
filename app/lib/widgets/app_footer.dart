import 'package:flutter/material.dart';

/// TerraON — AppFooter (versão final)
///
/// Rodapé simples e responsivo com links de navegação reais.
/// Aparece na maioria das páginas (exceto splash ou fullscreens).
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 16,
            alignment: WrapAlignment.center,
            children: [
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/terms'),
                child: const Text('Termos de Uso'),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/about'),
                child: const Text('Sobre o TerraON'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '© ${DateTime.now().year} TerraON — Cidadania e Meio Ambiente',
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
