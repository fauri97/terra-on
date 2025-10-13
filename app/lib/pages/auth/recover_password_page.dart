import 'package:flutter/material.dart';
import '../../widgets/app_navbar.dart';
import '../../widgets/app_footer.dart';

/// TerraON — RecoverPasswordPage
///
/// Página simples para recuperação de senha.
/// - Campo de e-mail e botão "Enviar instruções"
/// - Sem integração real (mostra apenas SnackBar)
/// - Inclui Navbar e Footer

class RecoverPasswordPage extends StatefulWidget {
  const RecoverPasswordPage({super.key});

  @override
  State<RecoverPasswordPage> createState() => _RecoverPasswordPageState();
}

class _RecoverPasswordPageState extends State<RecoverPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _loading = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Se existir conta, enviaremos instruções por e-mail.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const AppNavbar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mark_email_read_outlined,
                    size: 80,
                    color: scheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Recuperar senha',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Informe seu e-mail para enviarmos as instruções de redefinição.',
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Informe seu e-mail';
                      final email = v.trim();
                      final ok = RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(email);
                      if (!ok) return 'E-mail inválido';
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),
                  _loading
                      ? const CircularProgressIndicator()
                      : FilledButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.send_outlined),
                          label: const Text('Enviar instruções'),
                        ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Voltar'),
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

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
