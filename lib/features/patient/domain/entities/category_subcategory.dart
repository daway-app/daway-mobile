/// A category's sub-filter (e.g. a symptom under "أدوية", or a vitamin/
/// supplement kind under "فيتامينات ومكملات"). [groupKey] clusters related
/// subcategories together (e.g. 'symptoms', 'vitamins', 'supplements') for
/// grouped display in the filter sheet.
class CategorySubcategory {
  final int id;
  final String nameAr;
  final String slug;
  final String groupKey;

  const CategorySubcategory({
    required this.id,
    required this.nameAr,
    required this.slug,
    required this.groupKey,
  });
}
