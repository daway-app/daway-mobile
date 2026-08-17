class LocationPickerState {
  final double latitude;
  final double longitude;
  final String? address;
  final bool isResolvingAddress;
  final bool isSearching;
  final bool isLocating;
  final String? errorMessage;

  const LocationPickerState({
    required this.latitude,
    required this.longitude,
    this.address,
    this.isResolvingAddress = false,
    this.isSearching = false,
    this.isLocating = false,
    this.errorMessage,
  });

  LocationPickerState copyWith({
    double? latitude,
    double? longitude,
    String? address,
    bool? isResolvingAddress,
    bool? isSearching,
    bool? isLocating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LocationPickerState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      isResolvingAddress: isResolvingAddress ?? this.isResolvingAddress,
      isSearching: isSearching ?? this.isSearching,
      isLocating: isLocating ?? this.isLocating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
