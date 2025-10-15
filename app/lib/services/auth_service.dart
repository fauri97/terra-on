/// TerraON — AuthService (atualizado)
///
/// Interface de autenticação/conta usada pela UI.
/// Implementação local mínima em `local_impl.dart`.
///
/// Depois: será substituída por HttpAuthService (com backend C#).
///
/// Novidades:
/// - Suporte oficial a modo Visitante:
///   - `loginVisitor()`
///   - `isVisitor`
///   - Em modo visitante, o usuário pode apenas visualizar conteúdo público.
///     Não pode criar denúncia, curtir/comentar, etc. A UI (AppNavbar, páginas)
///     deve checar `isVisitor` para esconder/desabilitar ações.

abstract class AuthService {
  // ===== Login / Cadastro / Logout =====

  /// Login de pessoa física (usuário comum).
  Future<bool> loginUser({required String email, required String password});

  /// Login administrativo (prefeitura/ONG).
  Future<bool> loginAdmin({required String email, required String password});

  /// Entra como Visitante (sem conta).
  /// Deve limpar qualquer sessão anterior e marcar `isVisitor = true`.
  Future<void> loginVisitor();

  /// Registro de novo cidadão (não admin).
  /// Retorna true se o cadastro foi aceito (não faz login automático).
  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    String? city,
    String? uf, // adicionado
    String? avatarPath, // upload real no futuro (C# / storage)
    required bool acceptedTerms,
  });

  /// Logout do usuário atual (cidadão, admin ou visitante).
  Future<void> logout();

  // ===== Estado atual =====

  /// Indica se há sessão ativa (usuário ou admin).
  /// Obs.: Visitante NÃO é considerado "logado".
  bool get isLoggedIn;

  /// Indica se o usuário atual é admin.
  bool get isAdmin;

  /// Indica se o app está no modo Visitante.
  /// Em modo visitante:
  ///  - `isLoggedIn` deve ser false
  ///  - ações restritas na UI (ex.: criar denúncia) devem ser escondidas/desabilitadas
  bool get isVisitor;

  // ===== Dados do usuário logado (quando houver) =====

  String? get userName;
  String? get userEmail;
  String? get userCity;
  String? get userUF;
  String? get userPhotoPath;

  /// Atualiza dados de perfil/localização (em memória ou backend).
  void updateProfile({
    String? name,
    String? email,
    String? city,
    String? uf,
    String? photoPath,
  });
}
