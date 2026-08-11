class PharmacyAuthResponseModel {
  final String token;

  const PharmacyAuthResponseModel({required this.token});

  factory PharmacyAuthResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return PharmacyAuthResponseModel(token: data['token'] as String);
  }
}
