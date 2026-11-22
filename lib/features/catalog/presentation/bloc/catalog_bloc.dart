import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_testapp/core/constants/api_constants.dart';
import 'package:flutter_testapp/core/utils/input_sanitizer.dart';
import 'package:flutter_testapp/features/catalog/domain/entities/product.dart';
import 'package:flutter_testapp/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:flutter_testapp/features/catalog/presentation/bloc/catalog_event.dart';
import 'package:flutter_testapp/features/catalog/presentation/bloc/catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc({
    required CatalogRepository repository,
    Duration searchDebounce = ApiConstants.searchDebounce,
  })  : _repository = repository,
        super(const CatalogState()) {
    on<CatalogLoadRequested>(
      _onLoadRequested,
      transformer: _restartable<CatalogLoadRequested>(),
    );
    on<CatalogSearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: _debounceRestartableSearch(searchDebounce),
    );
    on<CatalogCategorySelected>(
      _onCategorySelected,
      transformer: _restartable<CatalogCategorySelected>(),
    );
    on<CatalogFiltersReset>(_onFiltersReset);
  }

  final CatalogRepository _repository;
  Timer? _searchDebounceTimer;

  Future<void> _onLoadRequested(
    CatalogLoadRequested event,
    Emitter<CatalogState> emit,
  ) async {
    emit(
      state.copyWith(
        status: CatalogStatus.loading,
        clearFailure: true,
      ),
    );

    final CatalogResult<List<Product>> result = await _repository.getProducts();
    switch (result) {
      case CatalogSuccess<List<Product>>(data: final List<Product> products):
        final List<Product> immutableProducts =
            List<Product>.unmodifiable(products);
        final List<String> categories = _extractCategories(immutableProducts);
        final String? validSelectedCategory =
            state.selectedCategory != null &&
                    categories.contains(state.selectedCategory)
                ? state.selectedCategory
                : null;
        final List<Product> filtered = _applyFilters(
          products: immutableProducts,
          query: state.searchQuery,
          category: validSelectedCategory,
        );

        emit(
          state.copyWith(
            status: CatalogStatus.success,
            allProducts: immutableProducts,
            filteredProducts: filtered,
            categories: categories,
            selectedCategory: validSelectedCategory,
            clearSelectedCategory: validSelectedCategory == null,
            clearFailure: true,
          ),
        );
      case CatalogFailure<List<Product>>(failure: final failure):
        emit(
          state.copyWith(
            status: CatalogStatus.failure,
            failure: failure,
          ),
        );
    }
  }

  void _onSearchQueryChanged(
    CatalogSearchQueryChanged event,
    Emitter<CatalogState> emit,
  ) {
    final String sanitized = InputSanitizer.sanitizeSearchQuery(event.query);
    final List<Product> filtered = _applyFilters(
      products: state.allProducts,
      query: sanitized,
      category: state.selectedCategory,
    );

    emit(
      state.copyWith(
        searchQuery: sanitized,
        filteredProducts: filtered,
      ),
    );
  }

  void _onCategorySelected(
    CatalogCategorySelected event,
    Emitter<CatalogState> emit,
  ) {
    final String? nextCategory = event.category;
    final List<Product> filtered = _applyFilters(
      products: state.allProducts,
      query: state.searchQuery,
      category: nextCategory,
    );

    emit(
      state.copyWith(
        selectedCategory: nextCategory,
        clearSelectedCategory: nextCategory == null,
        filteredProducts: filtered,
      ),
    );
  }

  void _onFiltersReset(
    CatalogFiltersReset event,
    Emitter<CatalogState> emit,
  ) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = null;
    emit(
      state.copyWith(
        searchQuery: '',
        clearSelectedCategory: true,
        filteredProducts: state.allProducts,
      ),
    );
  }

  @override
  Future<void> close() {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = null;
    return super.close();
  }

  static List<String> _extractCategories(List<Product> products) {
    final Set<String> uniqueCategories = <String>{};
    for (final Product product in products) {
      final String category = product.category.trim();
      if (category.isNotEmpty) {
        uniqueCategories.add(category);
      }
    }
    final List<String> sorted = uniqueCategories.toList()..sort();
    return List<String>.unmodifiable(sorted);
  }

  static List<Product> _applyFilters({
    required List<Product> products,
    required String query,
    required String? category,
  }) {
    final String normalizedQuery = query.toLowerCase();

    final List<Product> matches = <Product>[];
    for (final Product product in products) {
      if (category != null && product.category != category) {
        continue;
      }
      if (normalizedQuery.isNotEmpty &&
          !_matchesQuery(product, normalizedQuery)) {
        continue;
      }
      matches.add(product);
    }
    return List<Product>.unmodifiable(matches);
  }

  static bool _matchesQuery(Product product, String normalizedQuery) {
    return product.title.toLowerCase().contains(normalizedQuery) ||
        product.brand.toLowerCase().contains(normalizedQuery) ||
        product.category.toLowerCase().contains(normalizedQuery) ||
        product.description.toLowerCase().contains(normalizedQuery);
  }

  // Latest-request-wins: cancels in-flight work if a newer event arrives.
  static EventTransformer<E> _restartable<E>() {
    return (Stream<E> events, EventMapper<E> mapper) {
      late final StreamController<E> controller;
      StreamSubscription<E>? inputSub;
      StreamSubscription<E>? mapperSub;

      controller = StreamController<E>(
        onListen: () {
          inputSub = events.listen(
            (E event) {
              unawaited(mapperSub?.cancel());
              mapperSub = mapper(event).listen(
                controller.add,
                onError: controller.addError,
              );
            },
            onError: controller.addError,
          );
        },
        onCancel: () async {
          await mapperSub?.cancel();
          await inputSub?.cancel();
        },
      );

      return controller.stream;
    };
  }

  // Keep the debounce timer on the bloc so CatalogFiltersReset cancels pending searches.
  EventTransformer<CatalogSearchQueryChanged> _debounceRestartableSearch(
    Duration duration,
  ) {
    return (
      Stream<CatalogSearchQueryChanged> events,
      EventMapper<CatalogSearchQueryChanged> mapper,
    ) {
      late final StreamController<CatalogSearchQueryChanged> controller;
      StreamSubscription<CatalogSearchQueryChanged>? inputSub;
      StreamSubscription<CatalogSearchQueryChanged>? mapperSub;

      void startMapper(CatalogSearchQueryChanged event) {
        unawaited(mapperSub?.cancel());
        mapperSub = mapper(event).listen(
          controller.add,
          onError: controller.addError,
        );
      }

      controller = StreamController<CatalogSearchQueryChanged>(
        onListen: () {
          inputSub = events.listen(
            (CatalogSearchQueryChanged event) {
              _searchDebounceTimer?.cancel();
              if (duration == Duration.zero) {
                startMapper(event);
                return;
              }
              _searchDebounceTimer = Timer(duration, () => startMapper(event));
            },
            onError: controller.addError,
          );
        },
        onCancel: () async {
          _searchDebounceTimer?.cancel();
          _searchDebounceTimer = null;
          await mapperSub?.cancel();
          await inputSub?.cancel();
        },
      );

      return controller.stream;
    };
  }
}
