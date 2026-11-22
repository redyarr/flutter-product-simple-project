import 'package:equatable/equatable.dart';
import 'package:flutter_testapp/core/error/failures.dart';
import 'package:flutter_testapp/features/catalog/domain/entities/product.dart';

enum CatalogStatus {
  initial,
  loading,
  success,
  failure,
}

final class CatalogState extends Equatable {
  const CatalogState({
    this.status = CatalogStatus.initial,
    this.allProducts = const <Product>[],
    this.filteredProducts = const <Product>[],
    this.categories = const <String>[],
    this.selectedCategory,
    this.searchQuery = '',
    this.failure,
  });

  final CatalogStatus status;
  final List<Product> allProducts;
  final List<Product> filteredProducts;
  final List<String> categories;
  final String? selectedCategory;
  final String searchQuery;
  final Failure? failure;

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty || selectedCategory != null;

  CatalogState copyWith({
    CatalogStatus? status,
    List<Product>? allProducts,
    List<Product>? filteredProducts,
    List<String>? categories,
    String? selectedCategory,
    bool clearSelectedCategory = false,
    String? searchQuery,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return CatalogState(
      status: status ?? this.status,
      allProducts: allProducts ?? this.allProducts,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      categories: categories ?? this.categories,
      selectedCategory: clearSelectedCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        allProducts,
        filteredProducts,
        categories,
        selectedCategory,
        searchQuery,
        failure,
      ];
}
