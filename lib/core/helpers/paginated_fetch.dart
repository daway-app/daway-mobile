import 'dart:math' as math;

import 'json_list_extractor.dart';

/// Fetches every page of a paginated list endpoint and returns the items in
/// order. Such endpoints answer a fixed page size (20 for this backend, and
/// `per_page` is ignored), so reading only page 1 silently drops everything
/// after the first 20 items.
///
/// [fetchPage] returns the decoded response body of one page (1-based). The
/// page count is read from `pagination.last_page` (or `data.last_page`); a
/// response without one is a single page. At most [maxPages] pages are read,
/// so a wrong `last_page` cannot turn into an endless loop of requests.
///
/// A malformed page throws a [FormatException], like [extractJsonList].
Future<List<dynamic>> fetchAllPages({
  required Future<Object?> Function(int page) fetchPage,
  required String source,
  int maxPages = 25,
}) async {
  final first = await fetchPage(1);
  final items = List<dynamic>.of(extractJsonList(first, source: source));

  final lastPage = math.min(_lastPageOf(first), maxPages);
  for (var page = 2; page <= lastPage; page++) {
    items.addAll(extractJsonList(await fetchPage(page), source: source));
  }
  return items;
}

int _lastPageOf(Object? body) {
  if (body is! Map<String, dynamic>) return 1;
  final data = body['data'];
  for (final holder in [body['pagination'], if (data is Map) data]) {
    if (holder is Map && holder['last_page'] is num) {
      return math.max(1, (holder['last_page'] as num).toInt());
    }
  }
  return 1;
}
