import 'package:flutter/foundation.dart';
import 'package:flutter_testapp/core/error/exceptions.dart';
import 'package:flutter_testapp/core/error/failures.dart';
import 'package:flutter_testapp/features/catalog/data/datasources/catalog_remote_data_source.dart';
import 'package:flutter_testapp/features/catalog/data/models/product_model.dart';
import 'package:flutter_testapp/features/catalog/domain/entities/product.dart';
import 'package:flutter_testapp/features/catalog/domain/repositories/catalog_repository.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  const CatalogRepositoryImpl({
    required CatalogRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final CatalogRemoteDataSource _remoteDataSource;

  @override
  Future<CatalogResult<List<Product>>> getProducts() async {
    try {
      final List<ProductModel> models = await _remoteDataSource.fetchProducts();
      return CatalogSuccess<List<Product>>(List<Product>.unmodifiable(models));
    } on TimeoutException catch (error) {
      _logDebug('Timeout loading products: $error');
      return const CatalogFailure<List<Product>>(TimeoutFailure());
    } on NetworkException catch (error) {
      _logDebug('Network failure loading products: $error');
      return const CatalogFailure<List<Product>>(NetworkFailure());
    } on ServerException catch (error) {
      _logDebug('Server status ${error.statusCode} loading products.');
      return const CatalogFailure<List<Product>>(ServerFailure());
    } on DataParsingException catch (error) {
      _logDebug('Data parsing failure loading products: $error');
      return const CatalogFailure<List<Product>>(DataParsingFailure());
    } on Object catch (error) {
      _logDebug('Unexpected repository error: $error');
      return const CatalogFailure<List<Product>>(NetworkFailure());
    }
  }

  void _logDebug(String message) {
    if (kDebugMode) {
      debugPrint('[CatalogRepository] $message');
    }
  }
}
