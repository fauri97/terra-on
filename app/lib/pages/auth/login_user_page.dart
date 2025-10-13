import 'package:flutter/material.dart';
import '../../widgets/app_navbar.dart';
import '../../widgets/app_footer.dart';
import '../../services/service_locator.dart';

/// TerraON — LoginUserPage
///
/// Tela de login para cidadãos (Pessoa Física).
/// Após sucesso no login, o usuário é redirecionado para `/new-report`.
class LoginUserPage extends StatefulWidget {
  const LoginUserPage({super.key});

  @override
  State<LoginUserPage> createState() => _LoginUserPageState();
}

class _LoginUserPageState extends State<LoginUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _obscure = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final success = await authService.loginUser(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _loading = false);

    if (!mounted) return;

    if (success) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/new-report',
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falha no login. Verifique suas credenciais.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const AppNavbar(showNewReportButton: false),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Form(
            key: _formKey,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.lock_outline, size: 72, color: scheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Login (não administrativo)',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Informe seu e-mail.';
                      if (!v.contains('@')) return 'E-mail inválido.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Informe sua senha.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/recover'),
                      child: const Text('Esqueci minha senha'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _loading ? null : _login,
                    icon: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.login),
                    label: const Text('Entrar'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // ---- secundário: criar conta / visitante ----
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/register-user'),
                          icon: const Icon(Icons.person_add_alt_1),
                          label: const Text('Criar conta'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/choose-login'),
                          icon: const Icon(Icons.visibility),
                          label: const Text('Entrar como visitante'),
                        ),
                      ),
                    ],
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
    _passwordController.dispose();
    super.dispose();
  }
}
