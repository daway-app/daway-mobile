import '../../domain/entities/category.dart';

sealed class CategoriesState {
  const CategoriesState();
}

class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

class CategoriesLoaded extends CategoriesState {
  final List<Category> categories;

  const CategoriesLoaded(this.categories);
}

class CategoriesLoadFailure extends CategoriesState {
  final String message;

  const CategoriesLoadFailure(this.message);
}
