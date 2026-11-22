import 'package:flutter_testapp/core/constants/api_constants.dart';
import 'package:flutter_testapp/core/error/exceptions.dart';
import 'package:flutter_testapp/core/network/api_client.dart';
import 'package:flutter_testapp/features/catalog/data/models/product_model.dart';

abstract interface class CatalogRemoteDataSource {
  Future<List<ProductModel>> fetchProducts();
}

class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  const CatalogRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<ProductModel>> fetchProducts() async {
    final Uri uri = ApiConstants.buildUri(
      '/products',
      const <String, String>{'limit': ApiConstants.defaultCatalogLimit},
    );

    final Map<String, Object?> payload = await _apiClient.getJson(uri);
    final Object? rawProducts = payload['products'];
    if (rawProducts is! List<Object?>) {
      throw const DataParsingException('Missing or invalid "products" array.');
    }

    final List<ProductModel> products = <ProductModel>[];
    for (final Object? item in rawProducts) {
      if (item is! Map<Object?, Object?>) {
        throw const DataParsingException('Catalog item is not a JSON object.');
      }

      final Map<String, Object?> typedItem = <String, Object?>{};
      for (final MapEntry<Object?, Object?> entry in item.entries) {
        final Object? key = entry.key;
        if (key is String) {
          typedItem[key] = entry.value;
        }
      }
      products.add(ProductModel.fromJson(typedItem));
    }

    return List<ProductModel>.unmodifiable(products);
  }
}
