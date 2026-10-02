class PatientAuthResponseModel {
  final String? token;
  final bool isNewAccount;
  final int? userId;

  const PatientAuthResponseModel({this.token, required this.isNewAccount, this.userId});

  factory PatientAuthResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>;

    return PatientAuthResponseModel(
      token: data['token'] as String?,
      isNewAccount: user['is_new'] as bool? ?? false,
      userId: (user['id'] as num?)?.toInt(),
    );
  }
}
