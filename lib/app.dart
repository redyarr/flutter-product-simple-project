import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_testapp/core/theme/app_theme.dart';
import 'package:flutter_testapp/core/theme/theme_cubit.dart';
import 'package:flutter_testapp/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:flutter_testapp/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:flutter_testapp/features/catalog/presentation/bloc/catalog_event.dart';
import 'package:flutter_testapp/features/catalog/presentation/pages/catalog_page.dart';

class CatalogApp extends StatelessWidget {
  const CatalogApp({
    required this.catalogRepository,
    super.key,
  });

  final CatalogRepository catalogRepository;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<StateStreamableSource<Object?>>>[
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(),
        ),
        BlocProvider<CatalogBloc>(
          create: (_) => CatalogBloc(repository: catalogRepository)
            ..add(const CatalogLoadRequested()),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (BuildContext context, ThemeMode themeMode) {
          return MaterialApp(
            title: 'Curated Catalog',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const CatalogPage(),
          );
        },
      ),
    );
  }
}
