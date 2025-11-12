class ApiResponse<T> {
  final int statusCode;
  final String message;
  final T data;

  ApiResponse({
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromData,
  ) {
    return ApiResponse(
      statusCode: json['statusCode'] as int,
      message: json['message'] as String? ?? '',
      data: fromData(json['data'] as Map<String, dynamic>),
    );
  }
}

class LoginData {
  final int id;
  final String name;
  final String email;
  final String avatarBase64;
  final String accessToken;

  LoginData({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarBase64,
    required this.accessToken,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) => LoginData(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    avatarBase64: json['avatarBase64'] as String? ?? '',
    accessToken: json['accessToken'] as String? ?? '',
  );
}
