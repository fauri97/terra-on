import 'package:app/app_router.dart';
import 'package:app/core/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_navbar.dart';
import '../../widgets/app_footer.dart';
import '../../widgets/user_avatar_picker.dart';
import 'register_user_controller.dart';

class RegisterUserPage extends StatefulWidget {
  const RegisterUserPage({super.key});
  @override
  State<RegisterUserPage> createState() => _RegisterUserPageState();
}

class _RegisterUserPageState extends State<RegisterUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();

  final _passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');
  late final RegisterUserController c;

  @override
  void initState() {
    super.initState();
    final repo = context.read<AuthRepository>();
    c = RegisterUserController(repo)..init();
    c.addListener(_onChange);
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    c.removeListener(_onChange);
    c.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final validFields = _formKey.currentState!.validate();
    final hasUf = (c.stateName ?? '').trim().isNotEmpty;
    final hasCity = (c.city ?? '').trim().isNotEmpty;

    if (!validFields || !hasUf || !hasCity) {
      if (!hasUf) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione o Estado (UF).')),
        );
      } else if (!hasCity) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Selecione a Cidade.')));
      }
      return;
    }

    try {
      final ok = await c.submit(
        fullName: _nameCtrl.text,
        email: _emailCtrl.text,
        password: _passCtrl.text,
      );
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta criada! Faça login para continuar.'),
          ),
        );
        context.go(AppRouter.login);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível criar a conta.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  // --- Termos: bottom sheet simples com placeholder ---
  Future<void> _showTermsSheet() async {
    final text = Theme.of(context).textTheme;
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              children: [
                Text(
                  'Termos de Uso e Política de Privacidade',
                  style: text.titleLarge,
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 12),
                Text(
                  'Estes são termos e políticas de exemplo para o MVP. '
                  'Ao criar sua conta, você concorda com o tratamento dos dados '
                  'necessários para operar o TerraON e com o armazenamento de informações '
                  'relativas ao seu perfil e às suas denúncias. Você poderá solicitar a '
                  'remoção dos seus dados conforme a legislação aplicável.',
                  style: text.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Importante: denúncias públicas poderão exibir cidade e bairro. '
                  'Você pode optar por publicar de forma anônima nas telas de denúncia.',
                  style: text.bodyMedium,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Fechar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const AppNavbar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    'Criar conta',
                    style: text.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Avatar
                  UserAvatarPicker(
                    bytes: c.avatarBytes,
                    onPick: c.pickAvatar,
                    onRemove: c.removeAvatar,
                  ),

                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nome completo',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Informe seu nome'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Informe seu e-mail';
                      final ok = RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(v.trim());
                      return ok ? null : 'E-mail inválido';
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: Icon(Icons.lock_outline),
                      helperText: 'Mínimo 8 caracteres, com letra e número',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Informe uma senha';
                      return _passwordRegex.hasMatch(v) ? null : 'Senha fraca';
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pass2Ctrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar senha',
                      prefixIcon: Icon(Icons.lock_reset_outlined),
                    ),
                    validator: (v) =>
                        v == _passCtrl.text ? null : 'As senhas não coincidem',
                  ),

                  const SizedBox(height: 12),
                  // UF + Cidade (IBGE) + My Location
                  if (!c.loadingStates && c.states.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Não foi possível carregar os Estados (IBGE).',
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, bx) {
                        final compact = bx.maxWidth < 420; // breakpoint simples
                        final field = (Widget child) => compact
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: child,
                              )
                            : Expanded(child: child);

                        return compact
                            // EMPILHADO NO MOBILE
                            ? Column(
                                children: [
                                  DropdownButtonFormField<String>(
                                    value: c.stateName,
                                    isExpanded: true, // evita overflow
                                    items: c.states
                                        .map(
                                          (s) => DropdownMenuItem(
                                            value: s,
                                            child: Text(
                                              s,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) => c.onSelectState(v),
                                    decoration: const InputDecoration(
                                      labelText: 'Estado (UF)',
                                      prefixIcon: Icon(Icons.flag_outlined),
                                    ),
                                    validator: (_) =>
                                        (c.stateName == null ||
                                            c.stateName!.isEmpty)
                                        ? 'Selecione a UF'
                                        : null,
                                  ),
                                  DropdownButtonFormField<String>(
                                    value: c.city,
                                    isExpanded: true, // evita overflow
                                    items: c.cities
                                        .map(
                                          (s) => DropdownMenuItem(
                                            value: s,
                                            child: Text(
                                              s,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: c.loadingCities
                                        ? null
                                        : (v) => setState(() => c.city = v),
                                    decoration: const InputDecoration(
                                      labelText: 'Cidade',
                                      prefixIcon: Icon(
                                        Icons.location_city_outlined,
                                      ),
                                    ),
                                    validator: (_) =>
                                        (c.city == null || c.city!.isEmpty)
                                        ? 'Selecione a cidade'
                                        : null,
                                  ),
                                ],
                              )
                            // LADO A LADO EM TELAS LARGAS
                            : Row(
                                children: [
                                  field(
                                    DropdownButtonFormField<String>(
                                      value: c.stateName,
                                      isExpanded: true, // evita overflow
                                      items: c.states
                                          .map(
                                            (s) => DropdownMenuItem(
                                              value: s,
                                              child: Text(
                                                s,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (v) => c.onSelectState(v),
                                      decoration: const InputDecoration(
                                        labelText: 'Estado (UF)',
                                        prefixIcon: Icon(Icons.flag_outlined),
                                      ),
                                      validator: (_) =>
                                          (c.stateName == null ||
                                              c.stateName!.isEmpty)
                                          ? 'Selecione a UF'
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  field(
                                    DropdownButtonFormField<String>(
                                      value: c.city,
                                      isExpanded: true, // evita overflow
                                      items: c.cities
                                          .map(
                                            (s) => DropdownMenuItem(
                                              value: s,
                                              child: Text(
                                                s,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: c.loadingCities
                                          ? null
                                          : (v) => setState(() => c.city = v),
                                      decoration: const InputDecoration(
                                        labelText: 'Cidade',
                                        prefixIcon: Icon(
                                          Icons.location_city_outlined,
                                        ),
                                      ),
                                      validator: (_) =>
                                          (c.city == null || c.city!.isEmpty)
                                          ? 'Selecione a cidade'
                                          : null,
                                    ),
                                  ),
                                ],
                              );
                      },
                    ),

                  if (c.loadingCities)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: LinearProgressIndicator(minHeight: 2),
                    ),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () async {
                        final msg = await c.useMyLocation();
                        if (!mounted) return;
                        if (msg != null) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(msg)));
                        }
                      },
                      icon: const Icon(Icons.my_location),
                      label: const Text('Usar minha localização'),
                    ),
                  ),

                  const SizedBox(height: 8),
                  // Aceite dos Termos + Link "Ver Termos"
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CheckboxListTile(
                        value: c.acceptedTerms,
                        onChanged: (v) {
                          c.setAcceptedTerms(v ?? false);
                          if ((v ?? false) && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Você aceitou os Termos e a Política.',
                                ),
                              ),
                            );
                          }
                        },
                        title: const Text(
                          'Aceito os Termos e a Política de Privacidade',
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: _showTermsSheet,
                          child: const Text('Ver Termos e Política'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  c.loadingSubmit
                      ? const CircularProgressIndicator()
                      : FilledButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.person_add_alt_1),
                          label: const Text('Criar conta'),
                        ),

                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => context.go(AppRouter.login),
                    icon: const Icon(Icons.login),
                    label: const Text('Já tenho conta — entrar'),
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
