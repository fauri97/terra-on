class ApiListResponse<T> {
  final int statusCode;
  final String message;
  final List<T> data;

  ApiListResponse({
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory ApiListResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    final list = (json['data'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(fromItem)
        .toList();

    return ApiListResponse(
      statusCode: json['statusCode'] as int? ?? -1,
      message: json['message'] as String? ?? '',
      data: list,
    );
  }
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
  final List<String> imagesBase64;

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
    required this.imagesBase64,
  });

  factory ReportItem.fromJson(Map<String, dynamic> json) => ReportItem(
        description: json['description'] as String? ?? '',
        authorId: (json['authorId'] as num?)?.toInt() ?? 0,
        authorName: json['authorName'] as String? ?? 'Usuário',
        longitude: json['longitude'] as String? ?? '',
        latitude: json['latitude'] as String? ?? '',
        address: json['address'] as String? ?? '',
        city: json['city'] as String? ?? '',
        state: json['state'] as String? ?? '',
        bairro: json['bairro'] as String? ?? '',
        cep: json['cep'] as String? ?? '',
        imagesBase64: (json['imagesBase64'] as List<dynamic>? ?? [])
            .whereType<String>()
            .toList(),
      );
}
