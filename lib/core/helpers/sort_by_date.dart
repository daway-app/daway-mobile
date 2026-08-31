/// Sorts [items] newest-first by the date [dateOf] extracts from each one —
/// shared by every repository that shows a feed in reverse-chronological
/// order (ratings, notifications, ...) instead of each re-writing the same
/// comparator.
void sortByDateDescending<T>(List<T> items, DateTime Function(T) dateOf) {
  items.sort((a, b) => dateOf(b).compareTo(dateOf(a)));
}
