import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/patient/data/datasources/category_remote_data_source.dart';
import 'package:daway_app/features/patient/data/repositories/category_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubRemoteDataSource extends CategoryRemoteDataSource {
  Object? nextResponse;
  bool throws = false;

  _StubRemoteDataSource() : super(Dio());

  @override
  Future<Response<dynamic>> getCategories() async {
    if (throws) throw DioException(requestOptions: RequestOptions());
    return Response(requestOptions: RequestOptions(), data: nextResponse, statusCode: 200);
  }

  @override
  Future<Response<dynamic>> getCategoryMedicines({
    required String categorySlug,
    String? subcategorySlug,
    String? dosageForm,
    String? query,
    required int page,
    required int perPage,
  }) async {
    if (throws) throw DioException(requestOptions: RequestOptions());
    return Response(requestOptions: RequestOptions(), data: nextResponse, statusCode: 200);
  }

  @override
  Future<Response<dynamic>> getDosageForms() async {
    if (throws) throw DioException(requestOptions: RequestOptions());
    return Response(requestOptions: RequestOptions(), data: nextResponse, statusCode: 200);
  }
}

void main() {
  late _StubRemoteDataSource remoteDataSource;
  late CategoryRepositoryImpl repository;

  setUp(() {
    remoteDataSource = _StubRemoteDataSource();
    repository = CategoryRepositoryImpl(remoteDataSource);
  });

  test('parses the categories list out of the data envelope', () async {
    remoteDataSource.nextResponse = {
      'success': true,
      'data': [
        {'id': 3, 'name_ar': 'أدوية', 'slug': 'medicines', 'image': null},
        {'id': 4, 'name_ar': 'العناية بالأسنان', 'slug': 'dental-care', 'image': null},
      ],
    };

    final result = await repository.getCategories();

    expect(result, isA<Success<Object?>>());
    final categories = (result as Success).data;
    expect(categories, hasLength(2));
    expect(categories.first.nameAr, 'أدوية');
    expect(categories.last.slug, 'dental-care');
  });

  test('surfaces a network failure instead of throwing', () async {
    remoteDataSource.throws = true;

    final result = await repository.getCategories();

    expect(result, isA<ApiError<Object?>>());
  });

  test('an unexpected response shape is mapped to a failure, not an unhandled exception', () async {
    remoteDataSource.nextResponse = {'unexpected': 'shape'};

    final result = await repository.getCategories();

    expect(result, isA<ApiError<Object?>>());
  });

  test('parses category medicines with their pagination info', () async {
    remoteDataSource.nextResponse = {
      'success': true,
      'data': [
        {'id': 2125, 'trade_name': 'A TO Z EFFERVESCENT TABLET', 'dosage_form': 'tablet'},
      ],
      'pagination': {'total': 474, 'per_page': 20, 'current_page': 1, 'last_page': 24},
    };

    final result = await repository.getCategoryMedicines(categorySlug: 'vitamins-supplements');

    expect(result, isA<Success<Object?>>());
    final page = (result as Success).data;
    expect(page.medicines, hasLength(1));
    expect(page.medicines.first.tradeName, 'A TO Z EFFERVESCENT TABLET');
    expect(page.total, 474);
    expect(page.currentPage, 1);
    expect(page.lastPage, 24);
  });

  test('a missing pagination object is mapped to a failure, not an unhandled exception', () async {
    remoteDataSource.nextResponse = {'success': true, 'data': []};

    final result = await repository.getCategoryMedicines(categorySlug: 'vitamins-supplements');

    expect(result, isA<ApiError<Object?>>());
  });

  test('parses the dosage forms list', () async {
    remoteDataSource.nextResponse = {
      'success': true,
      'data': ['حبوب', 'شراب', 'كريم'],
    };

    final result = await repository.getDosageForms();

    expect(result, isA<Success<Object?>>());
    expect((result as Success).data, ['حبوب', 'شراب', 'كريم']);
  });
}
