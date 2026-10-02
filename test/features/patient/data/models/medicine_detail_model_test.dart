import 'package:daway_app/features/patient/data/models/medicine_detail_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a medicine out of the GET /medicines/{id} data envelope', () {
    final model = MedicineDetailModel.fromJson({
      'success': true,
      'message': 'تم جلب الدواء بنجاح',
      'data': {
        'id': 1,
        'trade_name': 'Panadol',
        'active_ingredient': 'Paracetamol',
        'image_url': 'https://example.com/panadol.jpg',
        'is_available': 1,
      },
    });

    final entity = model.toEntity();

    expect(entity.id, 1);
    expect(entity.tradeName, 'Panadol');
    expect(entity.imageUrl, 'https://example.com/panadol.jpg');
    // No tags field in the response yet (see MedicineDetail.tags doc comment).
    expect(entity.tags, isEmpty);
  });

  test('falls back to nulls/zero for missing optional fields', () {
    final model = MedicineDetailModel.fromJson({'data': <String, dynamic>{}});

    final entity = model.toEntity();

    expect(entity.id, 0);
    expect(entity.tradeName, '');
    expect(entity.imageUrl, isNull);
  });
}
