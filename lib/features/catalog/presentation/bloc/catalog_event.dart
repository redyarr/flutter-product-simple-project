import 'package:equatable/equatable.dart';

sealed class CatalogEvent extends Equatable {
  const CatalogEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class CatalogLoadRequested extends CatalogEvent {
  const CatalogLoadRequested();
}

final class CatalogSearchQueryChanged extends CatalogEvent {
  const CatalogSearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}

final class CatalogCategorySelected extends CatalogEvent {
  // Null selects "All" categories.
  const CatalogCategorySelected(this.category);

  final String? category;

  @override
  List<Object?> get props => <Object?>[category];
}

final class CatalogFiltersReset extends CatalogEvent {
  const CatalogFiltersReset();
}
