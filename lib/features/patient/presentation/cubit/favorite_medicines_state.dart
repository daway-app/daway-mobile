import '../../domain/entities/favorite_medicine.dart';

sealed class FavoriteMedicinesState {
  const FavoriteMedicinesState();
}

class FavoriteMedicinesLoading extends FavoriteMedicinesState {
  const FavoriteMedicinesLoading();
}

class FavoriteMedicinesLoadFailure extends FavoriteMedicinesState {
  final String message;

  const FavoriteMedicinesLoadFailure(this.message);
}

class FavoriteMedicinesLoaded extends FavoriteMedicinesState {
  final List<FavoriteMedicine> medicines;

  const FavoriteMedicinesLoaded(this.medicines);
}
