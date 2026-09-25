/// Formats a price for display: whole amounts without decimals ("60"), any
/// other amount with two ("12.50"). Rounding a price to whole shekels would
/// misstate it (19.9 shown as 20), which matters in a price-comparison app.
String formatPrice(double price) {
  final cents = (price * 100).round();
  return cents % 100 == 0 ? (cents ~/ 100).toString() : (cents / 100).toStringAsFixed(2);
}
