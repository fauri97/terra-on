import 'auth_service.dart';
import 'report_service.dart';

/// TerraON — Implementações locais mínimas (sem backend)
///
/// Objetivo: permitir que a UI funcione sem dados falsos.
/// Nenhum dado é salvo ou persistido.
/// Apenas garante que as chamadas retornem respostas neutras ([], null, false).

/// Implementação local mínima do AuthService.
class LocalAuthService implements AuthService {
  bool _loggedIn = false;
  bool _admin = false;

  // ===== Modo Visitante =====
  bool _visitor = false;

  // === Dados do usuário logado (mantidos em memória) ===
  String? _userName;
  String? _userEmail;
  String? _userCity;
  String? _userUF;
  String? _userPhotoPath;

  @override
  Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _loggedIn = true;
    _admin = false;
    _visitor = false; // login "real" cancela modo visitante
    _userEmail = email;
    _userName = 'Usuário Local';
    return true;
  }

  @override
  Future<bool> loginAdmin({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _loggedIn = true;
    _admin = true;
    _visitor = false; // admin cancela modo visitante
    _userEmail = email;
    _userName = 'Administrador Local';
    return true;
  }

  /// Entra como Visitante (sem conta).
  /// Limpa qualquer sessão anterior e marca _visitor=true.
  @override
  Future<void> loginVisitor() async {
    await Future.delayed(const Duration(milliseconds: 150));
    _loggedIn = false;
    _admin = false;
    _visitor = true;

    // Visitante não tem perfil:
    _userName = null;
    _userEmail = null;
    _userCity = null;
    _userUF = null;
    _userPhotoPath = null;
  }

  @override
  Future<bool> registerUser({
    required String fullName,
    required String email,
    required String password,
    String? city,
    String? uf,
    String? avatarPath,
    required bool acceptedTerms,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Local: apenas aceita o cadastro; não faz login automático.
    _userName = fullName;
    _userEmail = email;
    _userCity = city;
    _userUF = uf;
    _userPhotoPath = avatarPath;

    // Cadastro cancela estado visitante (mas não autentica):
    _visitor = false;
    return true;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _loggedIn = false;
    _admin = false;
    _visitor = false; // sai também do modo visitante
    _userName = null;
    _userEmail = null;
    _userCity = null;
    _userUF = null;
    _userPhotoPath = null;
  }

  @override
  bool get isLoggedIn => _loggedIn;

  @override
  bool get isAdmin => _admin;

  /// Indica se o app está no modo Visitante.
  /// Em modo visitante, `isLoggedIn` é false e ações restritas devem ser ocultadas/desativadas.
  @override
  bool get isVisitor => _visitor;

  // === Getters de dados do perfil ===
  @override
  String? get userName => _userName;

  @override
  String? get userEmail => _userEmail;

  @override
  String? get userCity => _userCity;

  @override
  String? get userUF => _userUF;

  @override
  String? get userPhotoPath => _userPhotoPath;

  @override
  void updateProfile({
    String? name,
    String? email,
    String? city,
    String? uf,
    String? photoPath,
  }) {
    if (name != null) _userName = name;
    if (email != null) _userEmail = email;
    if (city != null) _userCity = city;
    if (uf != null) _userUF = uf;
    if (photoPath != null) _userPhotoPath = photoPath;
  }
}

/// Implementação local mínima do ReportService.
class LocalReportService implements ReportService {
  @override
  Future<List<ReportSummary>> getPublicReports({
    String? city,
    String? district,
    ReportCategory? category,
    ReportStatus? status,
    ReportPeriod? period,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return []; // sem dados fake
  }

  @override
  Future<List<ReportSummary>> getMyReports() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return []; // histórico vazio no modo local
  }

  @override
  Future<ReportDetail?> getReportById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return null; // sem detalhe local
  }

  @override
  Future<String?> createReport(CreateReportInput input) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Local: não gera ID (retorna null). A UI deve lidar com estado neutro.
    return null;
  }

  @override
  Future<bool> editReport(String id, EditReportInput input) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return false; // local não altera nada
  }

  @override
  Future<bool> deleteReport(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return false; // local não deleta
  }

  @override
  Future<bool> assumeReport(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return false; // admin local não assume
  }

  @override
  Future<bool> likeReport(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return false; // like desativado no local
  }

  @override
  Future<Uri?> exportReportsCsv({
    String? city,
    String? district,
    ReportCategory? category,
    ReportStatus? status,
    ReportPeriod? period,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return null; // sem export local
  }

  @override
  Future<Uri?> exportReportsPdf({
    String? city,
    String? district,
    ReportCategory? category,
    ReportStatus? status,
    ReportPeriod? period,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return null; // sem export local
  }
}
