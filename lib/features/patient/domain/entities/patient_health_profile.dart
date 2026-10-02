/// Blood groups the patient can pick from.
const bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

/// The patient's medical profile (`/patient/health-profile`).
class PatientHealthProfile {
  final List<String> allergies;
  final List<String> chronicDiseases;
  final String? bloodType;
  final String notes;

  const PatientHealthProfile({
    this.allergies = const [],
    this.chronicDiseases = const [],
    this.bloodType,
    this.notes = '',
  });
}
