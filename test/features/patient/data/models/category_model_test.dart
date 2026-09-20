import 'package:daway_app/features/patient/data/models/category_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategoryModel.fromJson', () {
    test('parses a category with an image', () {
      final json = {
        'id': 3,
        'name_ar': 'أدوية',
        'name_en': 'Medicines',
        'slug': 'medicines',
        'image': 'https://res.cloudinary.com/demo/medicines.png',
        'is_active': true,
        'sort_order': 1,
        'medicines_count': 5124,
      };

      final model = CategoryModel.fromJson(json);

      expect(model.id, 3);
      expect(model.nameAr, 'أدوية');
      expect(model.slug, 'medicines');
      expect(model.image, 'https://res.cloudinary.com/demo/medicines.png');
    });

    test('a null image (a category with no artwork yet) does not fail parsing', () {
      final json = {
        'id': 4,
        'name_ar': 'العناية بالأسنان',
        'slug': 'dental-care',
        'image': null,
      };

      final model = CategoryModel.fromJson(json);

      expect(model.image, isNull);
    });

    test('a missing name_ar degrades to an empty string instead of throwing', () {
      final json = {'id': 5, 'slug': 'first-aid'};

      final model = CategoryModel.fromJson(json);

      expect(model.nameAr, '');
    });

    test('toEntity carries every field over', () {
      const model = CategoryModel(
        id: 3,
        nameAr: 'أدوية',
        slug: 'medicines',
        image: 'https://example.com/img.png',
      );

      final entity = model.toEntity();

      expect(entity.id, 3);
      expect(entity.nameAr, 'أدوية');
      expect(entity.slug, 'medicines');
      expect(entity.image, 'https://example.com/img.png');
    });
  });
}
