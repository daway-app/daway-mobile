import 'package:daway_app/features/patient/data/models/order_model.dart';
import 'package:daway_app/features/patient/domain/entities/order.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses an order row from GET /patient/orders', () {
    final model = OrderModel.fromJson({
      'id': 1,
      'total': 25.0,
      'status': 'confirmed',
      'items_count': 2,
      'address': {'id': 1, 'label': 'المنزل', 'address': 'غزة - الرمال'},
      'pharmacy': {'id': 1, 'name': 'صيدلية الأمل'},
      'created_at': '2026-09-29 10:20:29',
    });

    final entity = model.toEntity();

    expect(entity.orderNumber, '1');
    expect(entity.pharmacyName, 'صيدلية الأمل');
    expect(entity.status, OrderStatus.confirmed);
    expect(entity.itemsCount, 2);
    expect(entity.price, 25.0);
    expect(entity.address, 'غزة - الرمال');
    // created_at has no timezone marker, so it's the server's UTC clock (see
    // server_timestamp.dart) — compare the instant, not local wall-clock
    // fields, so this holds in whatever timezone the tests run in.
    expect(
      entity.createdAt.isAtSameMomentAs(DateTime.utc(2026, 9, 29, 10, 20, 29)),
      isTrue,
    );
  });

  test('falls back to the address label when it has no address text', () {
    final model = OrderModel.fromJson({
      'address': {'id': 1, 'label': 'المنزل'},
      'created_at': '2026-09-29 10:20:29',
    });

    expect(model.toEntity().address, 'المنزل');
  });

  test('an unrecognized status defaults to pending instead of throwing', () {
    final model = OrderModel.fromJson({'status': 'some_new_status'});

    expect(model.toEntity().status, OrderStatus.pending);
  });

  test('a malformed created_at falls back instead of throwing and failing the whole list',
      () {
    final model = OrderModel.fromJson({'id': 1, 'created_at': 'not-a-date'});

    // Doesn't throw — this order still parses, just with a fallback date,
    // instead of a bad date on one order breaking every order in the list.
    expect(model.toEntity().createdAt, isA<DateTime>());
  });

  test('falls back to nulls/zero/empty for missing fields', () {
    final entity = OrderModel.fromJson({}).toEntity();

    expect(entity.orderNumber, '');
    expect(entity.pharmacyName, '');
    expect(entity.itemsCount, 0);
    expect(entity.price, 0);
    expect(entity.address, '');
  });
}
