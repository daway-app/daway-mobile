/// A counted noun in correct Arabic agreement: 1 gives the [singular] alone
/// (or [one], when a fuller phrase such as "صيدلية واحدة" is wanted), 2 the
/// [dual] alone, 3-10 the number with the [plural] ("5 دقائق"), and 11 or
/// more the number with the [singular] ("20 دقيقة").
///
/// Getting this right matters wherever a count is shown next to a noun: a
/// fixed plural reads "1 صيدليات", which is plainly wrong for the most common
/// counts.
String arabicCountedNoun(
  int count, {
  required String singular,
  required String dual,
  required String plural,
  String? one,
}) {
  if (count == 1) return one ?? singular;
  if (count == 2) return dual;
  if (count >= 3 && count <= 10) return '$count $plural';
  return '$count $singular';
}
