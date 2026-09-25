import 'package:daway_app/core/helpers/paginated_fetch.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// A backend with [totalPages] pages of [perPage] numbered items, in the
  /// `{data: [...], pagination: {...}}` shape the patient endpoints use.
  Map<String, dynamic> page(int number, {required int totalPages, int perPage = 2}) {
    return {
      'success': true,
      'data': [for (var i = 0; i < perPage; i++) (number - 1) * perPage + i + 1],
      'pagination': {
        'total': totalPages * perPage,
        'per_page': perPage,
        'current_page': number,
        'last_page': totalPages,
      },
    };
  }

  test('reads every page and returns the items in order', () async {
    final requested = <int>[];

    final items = await fetchAllPages(
      source: 'GET /things',
      fetchPage: (number) async {
        requested.add(number);
        return page(number, totalPages: 3);
      },
    );

    expect(requested, [1, 2, 3]);
    expect(items, [1, 2, 3, 4, 5, 6]);
  });

  test('a single page costs a single request', () async {
    var requests = 0;

    final items = await fetchAllPages(
      source: 'GET /things',
      fetchPage: (number) async {
        requests++;
        return page(number, totalPages: 1);
      },
    );

    expect(requests, 1);
    expect(items, [1, 2]);
  });

  test('a response with no pagination info is one page', () async {
    var requests = 0;

    final items = await fetchAllPages(
      source: 'GET /things',
      fetchPage: (number) async {
        requests++;
        return {'data': [7, 8, 9]};
      },
    );

    expect(requests, 1);
    expect(items, [7, 8, 9]);
  });

  test('a bare list is one page', () async {
    final items = await fetchAllPages(
      source: 'GET /things',
      fetchPage: (number) async => [1, 2],
    );

    expect(items, [1, 2]);
  });

  test('understands the nested paginator shape, {data: {data: [...], last_page: n}}', () async {
    final requested = <int>[];

    final items = await fetchAllPages(
      source: 'GET /things',
      fetchPage: (number) async {
        requested.add(number);
        return {
          'data': {
            'data': [number],
            'last_page': 2,
          },
        };
      },
    );

    expect(requested, [1, 2]);
    expect(items, [1, 2]);
  });

  test('stops at maxPages, so a wrong last_page cannot loop forever', () async {
    final requested = <int>[];

    final items = await fetchAllPages(
      source: 'GET /things',
      maxPages: 3,
      fetchPage: (number) async {
        requested.add(number);
        return page(number, totalPages: 1000);
      },
    );

    expect(requested, [1, 2, 3]);
    expect(items, hasLength(6));
  });

  test('a last_page below 1 is still one page', () async {
    var requests = 0;

    await fetchAllPages(
      source: 'GET /things',
      fetchPage: (number) async {
        requests++;
        return page(number, totalPages: 0);
      },
    );

    expect(requests, 1);
  });

  test('a malformed page throws, naming the source', () async {
    expect(
      () => fetchAllPages(source: 'GET /things', fetchPage: (number) async => 'oops'),
      throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('GET /things'))),
    );
  });
}
