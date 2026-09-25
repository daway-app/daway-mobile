import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/patient/data/datasources/favorites_remote_data_source.dart';
import 'package:daway_app/features/patient/data/repositories/favorites_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubRemoteDataSource extends FavoritesRemoteDataSource {
  /// The body served for each 1-based page.
  final Map<int, Object?> pages = {};
  bool throws = false;
  int? throwsOnPage;
  String? lastToken;
  final List<int> requestedPages = [];

  _StubRemoteDataSource() : super(Dio());

  /// The body of page 1, for the single-page cases.
  set nextResponse(Object? value) => pages[1] = value;

  @override
  Future<Response<dynamic>> getFavoriteMedicines({required String token, int page = 1}) async {
    lastToken = token;
    requestedPages.add(page);
    if (throws || throwsOnPage == page) throw DioException(requestOptions: RequestOptions());
    return Response(requestOptions: RequestOptions(), data: pages[page], statusCode: 200);
  }
}

Map<String, dynamic> _favorite(int id) => {
      'medicine_id': id,
      'trade_name': 'Medicine $id',
      'is_available': true,
      'pharmacies_count': 1,
      'min_price': 10,
    };

Map<String, dynamic> _page(List<Map<String, dynamic>> items, {required int number, required int lastPage}) => {
      'success': true,
      'data': items,
      'pagination': {'total': 3, 'per_page': 2, 'current_page': number, 'last_page': lastPage},
    };

void main() {
  late _StubRemoteDataSource remoteDataSource;
  late FavoritesRepositoryImpl repository;

  setUp(() {
    remoteDataSource = _StubRemoteDataSource();
    repository = FavoritesRepositoryImpl(remoteDataSource);
  });

  test('parses the favorite medicines out of the data envelope, passing the token through', () async {
    remoteDataSource.nextResponse = {
      'success': true,
      'data': [
        {
          'medicine_id': 1,
          'trade_name': 'Panadol',
          'is_available': true,
          'pharmacies_count': 1,
          'min_price': 60,
        },
      ],
      'pagination': {'total': 1, 'per_page': 20, 'current_page': 1, 'last_page': 1},
    };

    final result = await repository.getFavoriteMedicines(token: 'tok-1');

    expect(remoteDataSource.lastToken, 'tok-1');
    expect(result, isA<Success<Object?>>());
    final medicines = (result as Success).data;
    expect(medicines, hasLength(1));
    expect(medicines.single.tradeName, 'Panadol');
  });

  test('an empty list is a valid, non-error result', () async {
    remoteDataSource.nextResponse = {
      'success': true,
      'data': [],
      'pagination': {'total': 0, 'per_page': 20, 'current_page': 1, 'last_page': 1},
    };

    final result = await repository.getFavoriteMedicines(token: 'tok-1');

    expect(result, isA<Success<Object?>>());
    expect((result as Success).data, isEmpty);
  });

  test('surfaces a network failure instead of throwing', () async {
    remoteDataSource.throws = true;

    final result = await repository.getFavoriteMedicines(token: 'tok-1');

    expect(result, isA<ApiError<Object?>>());
  });

  test('an unexpected response shape is mapped to a failure, not an unhandled exception', () async {
    remoteDataSource.nextResponse = {'unexpected': 'shape'};

    final result = await repository.getFavoriteMedicines(token: 'tok-1');

    expect(result, isA<ApiError<Object?>>());
  });

  test('reads every page, so favorites beyond the first page are not silently dropped', () async {
    remoteDataSource.pages[1] = _page([_favorite(1), _favorite(2)], number: 1, lastPage: 2);
    remoteDataSource.pages[2] = _page([_favorite(3)], number: 2, lastPage: 2);

    final result = await repository.getFavoriteMedicines(token: 'tok-1');

    expect(remoteDataSource.requestedPages, [1, 2]);
    expect((result as Success).data.map((m) => m.medicineId), [1, 2, 3]);
  });

  test('a single page costs a single request', () async {
    remoteDataSource.pages[1] = _page([_favorite(1)], number: 1, lastPage: 1);

    await repository.getFavoriteMedicines(token: 'tok-1');

    expect(remoteDataSource.requestedPages, [1]);
  });

  test('a failure on a later page fails the whole list rather than returning a partial one', () async {
    remoteDataSource.pages[1] = _page([_favorite(1), _favorite(2)], number: 1, lastPage: 2);
    remoteDataSource.throwsOnPage = 2;

    final result = await repository.getFavoriteMedicines(token: 'tok-1');

    expect(result, isA<ApiError<Object?>>());
  });
}
