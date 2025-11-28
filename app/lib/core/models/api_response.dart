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
    T Function(Map<String, dynamic> item) parseItem,
  ) {
    final status = json['statusCode'] ?? json['StatusCode'] ?? 0;
    final message = json['message'] ?? json['Message'] ?? '';

    final raw = json['data'] ?? json['Data'] ?? const [];
    final list = (raw is List) ? raw : const [];

    final parsed = list.map<T>((e) {
      if (e is Map) {
        return parseItem(Map<String, dynamic>.from(e));
      }
      return parseItem(<String, dynamic>{});
    }).toList();

    return ApiListResponse<T>(
      statusCode: status is int ? status : int.tryParse('$status') ?? 0,
      message: '$message',
      data: parsed,
    );
  }
}
