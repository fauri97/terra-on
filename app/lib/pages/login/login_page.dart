import 'dart:ui';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Fundo em gradiente
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F3D2E),
                  Color(0xFF1B5E20),
                  Color(0xFF91C788),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Elementos decorativos (bolhas)
          Positioned(
            top: -60,
            left: -40,
            child: _Bubble(size: 180, color: Colors.white.withOpacity(0.08)),
          ),
          Positioned(
            bottom: -50,
            right: -30,
            child: _Bubble(size: 140, color: Colors.white.withOpacity(0.08)),
          ),
          // Conteúdo com rolagem
          LayoutBuilder(
            builder: (context, constraints) {
              final maxW = constraints.maxWidth;
              final cardWidth = maxW < 520 ? maxW * 0.94 : 440.0;

              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: ConstrainedBox(
                    constraints: BoxConstraints.tightFor(width: cardWidth),
                    child: _GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 8),
                            // Logotipo / marca TerraON
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: cs.primary.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: cs.primary.withOpacity(0.35),
                                    ),
                                  ),
                                  child: Icon(Icons.public, color: cs.primary),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'TerraON',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Sua voz por uma cidade melhor',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: cs.onSurface.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Campos
                            TextField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: 'E-mail institucional',
                                prefixIcon: const Icon(Icons.email_outlined),
                                hintText: 'nome@prefeitura.gov.br',
                                filled: true,
                                fillColor: cs.surface.withOpacity(0.6),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: _pwdCtrl,
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                labelText: 'Senha',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  tooltip: _obscure
                                      ? 'Mostrar senha'
                                      : 'Ocultar senha',
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                                filled: true,
                                fillColor: cs.surface.withOpacity(0.6),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Esqueci a senha
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // TODO: navegar para fluxo de recuperação
                                },
                                child: const Text('Esqueci minha senha'),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Botão principal
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () {
                                  // TODO: acionar login (sem lógica aqui)
                                },
                                child: const Text('Entrar'),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Botão secundário (anônimo / visitante)
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.explore_outlined),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () {
                                  // TODO: continuar como visitante
                                },
                                label: const Text('Continuar como visitante'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Termos/aviso
                            Text(
                              'Ao continuar, você concorda com os termos de uso e privacidade.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurface.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // AppBar transparente
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // Opcional: Navigator.maybePop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cs.surface.withOpacity(0.45),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final double size;
  final Color color;
  const _Bubble({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: const [
          BoxShadow(blurRadius: 40, spreadRadius: 10, color: Colors.black12),
        ],
      ),
    );
  }
}
