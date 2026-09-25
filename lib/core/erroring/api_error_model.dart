class ApiErrorModel {
  final String? code;
  final String? message;
  final bool registrationRequired;

  const ApiErrorModel({this.code, this.message, this.registrationRequired = false});

  factory ApiErrorModel.fromJson(Map<String, dynamic> json) {
    return ApiErrorModel(
      code: _stringOrNull(json['code']) ??
          _stringOrNull(json['error_code']) ??
          _stringOrNull(json['errorCode']),
      message: _stringOrNull(json['message']) ??
          _stringOrNull(json['error']) ??
          _stringOrNull(json['msg']),
      registrationRequired: _flagOrFalse(json['registration_required']),
    );
  }
}

/// Some error responses (e.g. Cloudinary's unsigned-upload errors, shaped
/// `{"error": {"message": "..."}}`) put a nested object where this app's own
/// backend puts a plain string. A blind `as String?` cast throws on those
/// instead of falling through to the next candidate field, which left at
/// least one caller (avatar upload) stuck mid-request forever since the
/// thrown error never reached the code that would clear its loading state.
String? _stringOrNull(Object? value) => value is String ? value : null;

/// The backend sends `registration_required` as a boolean, but a 1 or "true"
/// means the same thing to it, and it must not matter which — a blind
/// `as bool?` cast throws on those, the same way the string casts above did.
/// Anything else is read as "not required". Nothing in [ApiErrorModel.fromJson]
/// throws, whatever types the response carries.
bool _flagOrFalse(Object? value) => value == true || value == 1 || value == 'true' || value == '1';
