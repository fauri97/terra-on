import 'package:flutter/material.dart';
import '../services/service_locator.dart';

/// TerraON — AppNavbar
///
/// Barra superior comum a todas as páginas.
/// Mostra o logotipo, botões de navegação e menu do perfil.
///
/// Reage ao estado de login via AuthService (mock local).
/// Agora com atalhos diretos e comportamento responsivo (web + mobile).
class AppNavbar extends StatelessWidget implements PreferredSizeWidget {
  /// Controla se o botão “Nova denúncia” aparece na barra (além do menu).
  final bool showNewReportButton;

  const AppNavbar({super.key, this.showNewReportButton = true});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLoggedIn = authService.isLoggedIn;
    final isAdmin = authService.isAdmin;

    // Largura para decidir quando colapsar os atalhos em um menu
    final width = MediaQuery.of(context).size.width;
    final collapse = width < 560; // breakpoint simples

    return AppBar(
      titleSpacing: 12,
      title: Row(
        children: [
          // Logo / Home
          InkWell(
            onTap: () => Navigator.pushNamed(context, '/choose-login'),
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

          // Ações à direita
          if (!collapse)
            Row(
              children: [
                // Explorar (público)
                TextButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/explore'),
                  icon: const Icon(Icons.travel_explore_outlined),
                  label: const Text('Explorar'),
                ),

                // Minhas denúncias (somente logado)
                if (isLoggedIn)
                  TextButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/my-reports'),
                    icon: const Icon(Icons.list_alt_outlined),
                    label: const Text('Minhas denúncias'),
                  ),

                // Nova denúncia (somente usuário logado não-admin)
                if (showNewReportButton && isLoggedIn && !isAdmin)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilledButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Nova denúncia'),
                      onPressed: () => Navigator.pushNamed(context, '/new-report'),
                    ),
                  ),

                const SizedBox(width: 8),
                _ProfileMenu(isLoggedIn: isLoggedIn, isAdmin: isAdmin),
              ],
            )
          else
            // Versão compacta (mobile): colapsa atalhos em um menu
            Row(
              children: [
                if (showNewReportButton && isLoggedIn && !isAdmin)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: IconButton.filled(
                      tooltip: 'Nova denúncia',
                      icon: const Icon(Icons.add),
                      onPressed: () => Navigator.pushNamed(context, '/new-report'),
                    ),
                  ),
                _CollapsedActions(isLoggedIn: isLoggedIn),
                const SizedBox(width: 4),
                _ProfileMenu(isLoggedIn: isLoggedIn, isAdmin: isAdmin),
              ],
            ),
        ],
      ),
    );
  }
}

/// Versão compacta dos atalhos (menu hamburger simples).
class _CollapsedActions extends StatelessWidget {
  const _CollapsedActions({required this.isLoggedIn});
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Menu',
      icon: const Icon(Icons.menu),
      onSelected: (value) async {
        switch (value) {
          case 'home':
            Navigator.pushNamed(context, '/choose-login');
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
  const _ProfileMenu({required this.isLoggedIn, required this.isAdmin});
  final bool isLoggedIn;
  final bool isAdmin;

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
            // Navigator.pushNamed(context, '/profile'); // quando a página estiver ativa
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Perfil indisponível (fase inicial).')),
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
            Navigator.pushNamed(context, '/about'); // segue disponível no menu do perfil
            break;
          case 'sair':
            await authService.logout();
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/choose-login',
                (route) => false,
              );
            }
            break;
          case 'entrar':
            Navigator.pushNamed(context, '/login-user');
            break;
        }
      },
      itemBuilder: (context) {
        return [
          if (isLoggedIn)
            const PopupMenuItem(
              value: 'perfil',
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text('Perfil'),
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
              child: ListTile(
                leading: Icon(Icons.logout),
                title: Text('Sair'),
              ),
            )
          else
            const PopupMenuItem(
              value: 'entrar',
              child: ListTile(
                leading: Icon(Icons.login),
                title: Text('Entrar'),
              ),
            ),
        ];
      },
    );
  }
}
