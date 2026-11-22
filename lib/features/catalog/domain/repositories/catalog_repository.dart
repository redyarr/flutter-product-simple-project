import 'package:equatable/equatable.dart';
import 'package:flutter_testapp/core/error/failures.dart';
import 'package:flutter_testapp/features/catalog/domain/entities/product.dart';

sealed class CatalogResult<T> extends Equatable {
  const CatalogResult();
}

final class CatalogSuccess<T> extends CatalogResult<T> {
  const CatalogSuccess(this.data);

  final T data;

  @override
  List<Object?> get props => <Object?>[data];
}

final class CatalogFailure<T> extends CatalogResult<T> {
  const CatalogFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => <Object?>[failure];
}

abstract interface class CatalogRepository {
  Future<CatalogResult<List<Product>>> getProducts();
}
