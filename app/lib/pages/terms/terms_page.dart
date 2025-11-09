import 'package:flutter/material.dart';
import '../../widgets/app_navbar.dart';
import '../../widgets/app_footer.dart';

/// TerraON — Termos de Uso (placeholder simples porém completo)
class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const AppNavbar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Termos de Uso',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '''
O TerraON é uma plataforma digital que tem como objetivo facilitar o registro e acompanhamento de denúncias relacionadas ao meio ambiente e ao espaço urbano.

Ao utilizar o sistema, o usuário concorda que todas as informações enviadas devem ser verdadeiras e baseadas em situações reais. Não é permitido criar, compartilhar ou publicar conteúdo falso, ofensivo, difamatório ou que viole a legislação vigente.

A plataforma pode armazenar dados necessários para funcionamento, como cidade, e-mail (quando o usuário possui conta) e informações relacionadas às denúncias. Fotos enviadas pelo usuário devem representar o fato denunciado.

O TerraON não se responsabiliza por análises, decisões, prazos de resposta ou ações realizadas pelas entidades públicas responsáveis. O sistema é apenas um meio de encaminhamento e registro.

Ao continuar utilizando o TerraON, você confirma que leu e aceita estes termos.
                  ''',
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                    height: 1.32,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }
}

