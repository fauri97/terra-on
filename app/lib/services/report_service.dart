/// TerraON — ReportService
///
/// Define a interface para manipulação de denúncias (reports).
/// Nesta fase, não há dados reais — apenas assinaturas e tipos.
/// A implementação local mínima está em `local_impl.dart`.

/// Representa um intervalo de tempo (sem depender de DateTimeRange do Material).
class ReportPeriod {
  final DateTime? start;
  final DateTime? end;
  const ReportPeriod({this.start, this.end});
}

/// Possíveis status de uma denúncia.
enum ReportStatus {
  aberta,
  triagem,
  andamento,
  resolvida,
  cancelada,
}

/// Categorias/tipos mais comuns de denúncia.
enum ReportCategory {
  lixo,
  esgoto,
  poda,
  iluminacao,
  buraco,
  poluicao,
  outro,
}

/// Modelo resumido de uma denúncia (para listagens e histórico).
class ReportSummary {
  final String id;
  final String title;
  final ReportCategory category;
  final String city;
  final String? district;
  final ReportStatus status;
  final DateTime createdAt;
  final bool isAnonymous;
  final int likeCount;
  final String? thumbnailUrl;

  const ReportSummary({
    required this.id,
    required this.title,
    required this.category,
    required this.city,
    this.district,
    required this.status,
    required this.createdAt,
    this.isAnonymous = false,
    this.likeCount = 0,
    this.thumbnailUrl,
  });
}

/// Modelo detalhado de uma denúncia (para tela de detalhes).
class ReportDetail {
  final String id;
  final String title;
  final String description;
  final ReportCategory category;
  final String city;
  final String? district;
  final ReportStatus status;
  final List<String> photos;
  final bool isAnonymous;
  final String? reporterName;
  final int likeCount;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;

  const ReportDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.city,
    this.district,
    required this.status,
    this.photos = const [],
    this.isAnonymous = false,
    this.reporterName,
    this.likeCount = 0,
    required this.createdAt,
    this.latitude,
    this.longitude,
  });
}

/// Dados necessários para criar uma denúncia.
class CreateReportInput {
  final String title;
  final String description;
  final ReportCategory category;
  final String city;
  final String? district;
  final bool isAnonymous;
  final List<String> photoPaths;
  final double? latitude;
  final double? longitude;

  const CreateReportInput({
    required this.title,
    required this.description,
    required this.category,
    required this.city,
    this.district,
    this.isAnonymous = false,
    this.photoPaths = const [],
    this.latitude,
    this.longitude,
  });
}

/// Dados para editar uma denúncia existente.
class EditReportInput {
  final String? title;
  final String? description;
  final ReportCategory? category;
  final ReportStatus? status;
  final bool? isAnonymous;

  const EditReportInput({
    this.title,
    this.description,
    this.category,
    this.status,
    this.isAnonymous,
  });
}

/// Interface principal de serviço de denúncias.
///
/// A UI deve sempre consumir métodos dessa interface, sem acessar dados diretos.
/// A implementação local (`LocalReportService`) retorna estados neutros (listas vazias, null, false).
abstract class ReportService {
  /// Retorna uma lista pública de denúncias, filtrável.
  Future<List<ReportSummary>> getPublicReports({
    String? city,
    String? district,
    ReportCategory? category,
    ReportStatus? status,
    ReportPeriod? period,
  });

  /// Retorna a lista de denúncias do cidadão logado (histórico).
  Future<List<ReportSummary>> getMyReports();

  /// Cria uma nova denúncia e retorna o ID, ou null se falhar.
  Future<String?> createReport(CreateReportInput input);

  /// Busca detalhes de uma denúncia específica.
  Future<ReportDetail?> getReportById(String id);

  /// Edita uma denúncia existente (se o usuário for o autor).
  Future<bool> editReport(String id, EditReportInput input);

  /// Exclui uma denúncia (se ainda não assumida por admin).
  Future<bool> deleteReport(String id);

  /// Admin: assume uma denúncia (marca como em andamento).
  Future<bool> assumeReport(String id);

  /// Cidadão logado: curte uma denúncia pública.
  Future<bool> likeReport(String id);

  /// Exporta denúncias filtradas em formato CSV (admin).
  Future<Uri?> exportReportsCsv({
    String? city,
    String? district,
    ReportCategory? category,
    ReportStatus? status,
    ReportPeriod? period,
  });

  /// Exporta denúncias filtradas em formato PDF (admin).
  Future<Uri?> exportReportsPdf({
    String? city,
    String? district,
    ReportCategory? category,
    ReportStatus? status,
    ReportPeriod? period,
  });
}
