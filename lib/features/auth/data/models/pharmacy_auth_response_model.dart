class PharmacyAuthResponseModel {
  final String token;
  final int? userId;

  const PharmacyAuthResponseModel({required this.token, this.userId});

  factory PharmacyAuthResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final user = data['user'];
    return PharmacyAuthResponseModel(
      token: data['token'] as String,
      userId: user is Map ? (user['id'] as num?)?.toInt() : null,
    );
  }
}
