// lib/core/models/report_models.dart
class ApiListResponse<T> {
  final int statusCode;
  final String? message;
  final List<T> data;

  ApiListResponse({
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory ApiListResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromMap,
  ) {
    final list = (json['data'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(fromMap)
        .toList();
    return ApiListResponse<T>(
      statusCode: json['statusCode'] is int ? json['statusCode'] as int : 0,
      message: json['message'] as String?,
      data: list,
    );
  }
}

class InlineImage {
  final String? base64;
  final String? contentType;
  final int? sizeBytes;

  InlineImage({this.base64, this.contentType, this.sizeBytes});

  factory InlineImage.fromMap(Map<String, dynamic>? m) {
    if (m == null) return InlineImage();
    return InlineImage(
      base64: m['base64'] as String?,
      contentType: m['contentType'] as String?,
      sizeBytes: m['sizeBytes'] is int ? m['sizeBytes'] as int : null,
    );
  }
}

class ReportImage {
  final int? id;
  final String? base64;
  final String? contentType;
  final int? sizeBytes;

  ReportImage({this.id, this.base64, this.contentType, this.sizeBytes});

  factory ReportImage.fromMap(Map<String, dynamic> m) => ReportImage(
    id: m['id'] is int ? m['id'] as int : null,
    base64: m['base64'] as String?,
    contentType: m['contentType'] as String?,
    sizeBytes: m['sizeBytes'] is int ? m['sizeBytes'] as int : null,
  );
}

class ReportComment {
  final int id;
  final String text;
  final int authorId;
  final String authorName;
  final InlineImage? authorAvatar;

  ReportComment({
    required this.id,
    required this.text,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
  });

  factory ReportComment.fromMap(Map<String, dynamic> m) => ReportComment(
    id: (m['id'] as num?)?.toInt() ?? 0,
    text: m['text'] as String? ?? '',
    authorId: (m['authorId'] as num?)?.toInt() ?? 0,
    authorName: m['authorName'] as String? ?? '',
    authorAvatar: InlineImage.fromMap(
      m['authorAvatar'] as Map<String, dynamic>?,
    ),
  );
}

class ReportItem {
  final String description;
  final int authorId;
  final String authorName;
  final String longitude;
  final String latitude;
  final String address;
  final String city;
  final String state;
  final String bairro;
  final String cep;

  final InlineImage? authorAvatar;
  final List<ReportComment> comments;
  final List<ReportImage> images;

  ReportItem({
    required this.description,
    required this.authorId,
    required this.authorName,
    required this.longitude,
    required this.latitude,
    required this.address,
    required this.city,
    required this.state,
    required this.bairro,
    required this.cep,
    required this.authorAvatar,
    required this.comments,
    required this.images,
  });

  factory ReportItem.fromJson(Map<String, dynamic> m) => ReportItem(
    description: m['description'] as String? ?? '',
    authorId: (m['authorId'] as num?)?.toInt() ?? 0,
    authorName: m['authorName'] as String? ?? '',
    longitude: m['longitude'] as String? ?? '',
    latitude: m['latitude'] as String? ?? '',
    address: m['address'] as String? ?? '',
    city: m['city'] as String? ?? '',
    state: m['state'] as String? ?? '',
    bairro: m['bairro'] as String? ?? '',
    cep: m['cep'] as String? ?? '',
    authorAvatar: InlineImage.fromMap(
      m['authorAvatar'] as Map<String, dynamic>?,
    ),
    comments: (m['comments'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ReportComment.fromMap)
        .toList(),
    images: (m['images'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ReportImage.fromMap)
        .toList(),
  );
}
