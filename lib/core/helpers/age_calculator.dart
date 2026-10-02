/// Whole years between [birthDate] (an ISO `yyyy-MM-dd` date) and [now]
/// (defaults to today). Null if [birthDate] can't be parsed.
int? ageFromBirthDate(String birthDate, {DateTime? now}) {
  final born = DateTime.tryParse(birthDate);
  if (born == null) return null;
  final today = now ?? DateTime.now();
  var age = today.year - born.year;
  final hadBirthday =
      today.month > born.month || (today.month == born.month && today.day >= born.day);
  if (!hadBirthday) age--;
  return age < 0 ? 0 : age;
}
