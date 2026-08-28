/// Pulls a list out of a Laravel-style JSON response body, tolerating the
/// shapes such an API commonly returns for an index endpoint: a bare array,
/// `{data: [...]}`, or a paginated `{data: {data: [...]}}`. Throws
/// [FormatException] on anything else instead of silently discarding
/// results. [source] (e.g. an endpoint name) is included in that message so
/// a crash report can tell which of this helper's callers hit it.
List<dynamic> extractJsonList(Object? data, {String source = 'response'}) {
  if (data is List) return data;
  if (data is Map<String, dynamic>) {
    final payload = data['data'];
    if (payload is List) return payload;
    if (payload is Map<String, dynamic> && payload['data'] is List) {
      return payload['data'] as List;
    }
  }
  throw FormatException('Unexpected $source list response shape: $data');
}
