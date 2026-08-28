import '../../domain/entities/medicine_catalog_item.dart';

class MedicineCatalogItemModel {
  final int id;
  final String name;
  final String? nameAr;

  /// Maps to the response's `sub` field — a secondary line the backend
  /// shows under the name (usually the active ingredient, sometimes the
  /// manufacturer for MOH-sourced entries).
  final String? activeIngredient;
  final String? imageUrl;

  /// The catalog source, e.g. `"medicine"` for the pharmacy's own general
  /// list vs a Ministry of Health entry — confirmed present on real
  /// responses but the full set of values isn't confirmed yet.
  final String? type;

  const MedicineCatalogItemModel({
    required this.id,
    required this.name,
    this.nameAr,
    this.activeIngredient,
    this.imageUrl,
    this.type,
  });

  factory MedicineCatalogItemModel.fromJson(Map<String, dynamic> json) {
    return MedicineCatalogItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      nameAr: json['name_ar'] as String?,
      activeIngredient: json['sub'] as String?,
      imageUrl: json['image_url'] as String?,
      type: json['type'] as String?,
    );
  }

  MedicineCatalogItem toEntity() => MedicineCatalogItem(
        id: id,
        name: name,
        nameAr: nameAr,
        activeIngredient: activeIngredient,
        imageUrl: imageUrl,
        type: type,
      );
}
