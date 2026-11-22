import 'package:flutter/material.dart';
import 'package:flutter_testapp/app.dart';
import 'package:flutter_testapp/core/network/api_client.dart';
import 'package:flutter_testapp/features/catalog/data/datasources/catalog_remote_data_source.dart';
import 'package:flutter_testapp/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:flutter_testapp/features/catalog/domain/repositories/catalog_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final ApiClient apiClient = ApiClient();
  final CatalogRemoteDataSource remoteDataSource =
      CatalogRemoteDataSourceImpl(apiClient: apiClient);
  final CatalogRepository catalogRepository =
      CatalogRepositoryImpl(remoteDataSource: remoteDataSource);

  runApp(CatalogApp(catalogRepository: catalogRepository));
}
