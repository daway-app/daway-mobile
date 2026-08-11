class ApiErrorModel {
  final String? code;
  final String? message;

  const ApiErrorModel({this.code, this.message});

  factory ApiErrorModel.fromJson(Map<String, dynamic> json) {
    return ApiErrorModel(
      code: json['code'] as String? ??
          json['error_code'] as String? ??
          json['errorCode'] as String?,
      message: json['message'] as String? ??
          json['error'] as String? ??
          json['msg'] as String?,
    );
  }
}
