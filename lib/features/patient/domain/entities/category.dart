import 'category_subcategory.dart';

class Category {
  final int id;
  final String nameAr;
  final String slug;
  final String? image;
  final List<CategorySubcategory> subcategories;

  const Category({
    required this.id,
    required this.nameAr,
    required this.slug,
    this.image,
    this.subcategories = const [],
  });
}
