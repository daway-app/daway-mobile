/// Form data carried across every state so the screen never loses what the
/// user has already entered while a submission or avatar upload is in flight.
class CompleteProfileFormData {
  final String phone;
  final String name;
  final String? avatarLocalPath;
  final String? avatarUrl;
  final bool isUploadingAvatar;
  final String? avatarError;
  final double? latitude;
  final double? longitude;
  final String? address;

  const CompleteProfileFormData({
    required this.phone,
    this.name = '',
    this.avatarLocalPath,
    this.avatarUrl,
    this.isUploadingAvatar = false,
    this.avatarError,
    this.latitude,
    this.longitude,
    this.address,
  });

  bool get hasLocation => latitude != null && longitude != null;

  bool get canSubmit => name.trim().isNotEmpty && hasLocation && !isUploadingAvatar;

  CompleteProfileFormData copyWith({
    String? name,
    String? avatarLocalPath,
    String? avatarUrl,
    bool? isUploadingAvatar,
    String? avatarError,
    bool clearAvatarError = false,
    double? latitude,
    double? longitude,
    String? address,
  }) {
    return CompleteProfileFormData(
      phone: phone,
      name: name ?? this.name,
      avatarLocalPath: avatarLocalPath ?? this.avatarLocalPath,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
      avatarError: clearAvatarError ? null : (avatarError ?? this.avatarError),
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
    );
  }
}

sealed class CompleteProfileState {
  final CompleteProfileFormData formData;

  const CompleteProfileState(this.formData);
}

class CompleteProfileInitial extends CompleteProfileState {
  const CompleteProfileInitial(super.formData);
}

class CompleteProfileLoading extends CompleteProfileState {
  const CompleteProfileLoading(super.formData);
}

class CompleteProfileSuccess extends CompleteProfileState {
  const CompleteProfileSuccess(super.formData);
}

class CompleteProfileFailure extends CompleteProfileState {
  final String message;

  const CompleteProfileFailure(super.formData, this.message);
}
