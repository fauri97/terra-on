import 'dart:ui';
import 'package:app/app_router.dart';
import 'package:app/core/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import '../core/tokens/token_store.dart';

class AppNavbar extends StatelessWidget implements PreferredSizeWidget {
  final bool showNewReportButton;
  const AppNavbar({super.key, this.showNewReportButton = true});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final collapse = width < 560;

    // MESMAS instâncias injetadas no main.dart
    final store = context.read<TokenStore>();
    final auth = context.read<AuthRepository>();

    return Observer(
      builder: (_) {
        final isLoggedIn =
            store.isLoggedIn; // reativo (depende de @observable token)
        final isAdmin = false; // ajuste quando tiver essa info

        return AppBar(
          titleSpacing: 12,
          title: Row(
            children: [
              InkWell(
                onTap: () => context.go(AppRouter.main),
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  children: [
                    Icon(Icons.public, color: scheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'TerraON',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (!collapse)
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/explore'),
                      icon: const Icon(Icons.travel_explore_outlined),
                      label: const Text('Explorar'),
                    ),
                    if (isLoggedIn)
                      TextButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/my-reports'),
                        icon: const Icon(Icons.list_alt_outlined),
                        label: const Text('Minhas denúncias'),
                      ),
                    if (showNewReportButton && isLoggedIn && !isAdmin)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilledButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Nova denúncia'),
                          onPressed: () =>
                              context.go(AppRouter.newReport),
                        ),
                      ),
                    const SizedBox(width: 8),
                    _ProfileMenu(
                      isLoggedIn: isLoggedIn,
                      isAdmin: isAdmin,
                      onLogout: () async {
                        await auth.logout();
                      },
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    if (showNewReportButton && isLoggedIn && !isAdmin)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: IconButton.filled(
                          tooltip: 'Nova denúncia',
                          icon: const Icon(Icons.add),
                          onPressed: () =>
                              context.go(AppRouter.newReport),
                        ),
                      ),
                    _CollapsedActions(isLoggedIn: isLoggedIn),
                    const SizedBox(width: 4),
                    _ProfileMenu(
                      isLoggedIn: isLoggedIn,
                      isAdmin: isAdmin,
                      onLogout: () async {
                        await auth.logout();
                      },
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CollapsedActions extends StatelessWidget {
  const _CollapsedActions({required this.isLoggedIn});
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Menu',
      icon: const Icon(Icons.menu),
      onSelected: (value) {
        switch (value) {
          case 'home':
            break;
          case 'explore':
            Navigator.pushNamed(context, '/explore');
            break;
          case 'myreports':
            Navigator.pushNamed(context, '/my-reports');
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'home',
          child: ListTile(
            leading: Icon(Icons.home_outlined),
            title: Text('Início'),
          ),
        ),
        const PopupMenuItem(
          value: 'explore',
          child: ListTile(
            leading: Icon(Icons.travel_explore_outlined),
            title: Text('Explorar'),
          ),
        ),
        if (isLoggedIn)
          const PopupMenuItem(
            value: 'myreports',
            child: ListTile(
              leading: Icon(Icons.list_alt_outlined),
              title: Text('Minhas denúncias'),
            ),
          ),
      ],
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu({
    required this.isLoggedIn,
    required this.isAdmin,
    required this.onLogout,
  });

  final bool isLoggedIn;
  final bool isAdmin;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return PopupMenuButton<String>(
      tooltip: 'Menu do perfil',
      icon: CircleAvatar(
        backgroundColor: scheme.primaryContainer,
        child: Icon(Icons.person, color: scheme.onPrimaryContainer),
      ),
      onSelected: (value) async {
        switch (value) {
          case 'perfil':
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Perfil indisponível (fase inicial).'),
              ),
            );
            break;
          case 'myreports':
            Navigator.pushNamed(context, '/my-reports');
            break;
          case 'config':
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Configurações em breve.')),
            );
            break;
          case 'termos':
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Página de Termos em breve.')),
            );
            break;
          case 'sobre':
            Navigator.pushNamed(context, '/about');
            break;
          case 'sair':
            await onLogout(); // zera token -> guard do GoRouter te manda pro login
            break;
          case 'entrar':
            context.go(AppRouter.login);
            break;
        }
      },
      itemBuilder: (context) => [
        if (isLoggedIn)
          const PopupMenuItem(
            value: 'perfil',
            child: ListTile(leading: Icon(Icons.person), title: Text('Perfil')),
          ),
        if (isLoggedIn)
          const PopupMenuItem(
            value: 'myreports',
            child: ListTile(
              leading: Icon(Icons.list_alt_outlined),
              title: Text('Minhas denúncias'),
            ),
          ),
        if (isLoggedIn && isAdmin)
          const PopupMenuItem(
            value: 'admin',
            enabled: false,
            child: ListTile(
              leading: Icon(Icons.admin_panel_settings),
              title: Text('Painel Admin (em breve)'),
            ),
          ),
        const PopupMenuItem(
          value: 'config',
          child: ListTile(
            leading: Icon(Icons.settings),
            title: Text('Configurações'),
          ),
        ),
        const PopupMenuItem(
          value: 'termos',
          child: ListTile(
            leading: Icon(Icons.description_outlined),
            title: Text('Termos de Uso'),
          ),
        ),
        const PopupMenuItem(
          value: 'sobre',
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Sobre o TerraON'),
          ),
        ),
        const PopupMenuDivider(),
        if (isLoggedIn)
          const PopupMenuItem(
            value: 'sair',
            child: ListTile(leading: Icon(Icons.logout), title: Text('Sair')),
          )
        else
          const PopupMenuItem(
            value: 'entrar',
            child: ListTile(leading: Icon(Icons.login), title: Text('Entrar')),
          ),
      ],
    );
  }
}
