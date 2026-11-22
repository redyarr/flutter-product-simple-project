import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_testapp/core/error/failures.dart';
import 'package:flutter_testapp/core/theme/app_spacing.dart';
import 'package:flutter_testapp/core/theme/theme_cubit.dart';
import 'package:flutter_testapp/features/catalog/domain/entities/product.dart';
import 'package:flutter_testapp/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:flutter_testapp/features/catalog/presentation/bloc/catalog_event.dart';
import 'package:flutter_testapp/features/catalog/presentation/bloc/catalog_state.dart';
import 'package:flutter_testapp/features/catalog/presentation/pages/product_details_page.dart';
import 'package:flutter_testapp/features/catalog/presentation/widgets/catalog_empty_state.dart';
import 'package:flutter_testapp/features/catalog/presentation/widgets/catalog_error_state.dart';
import 'package:flutter_testapp/features/catalog/presentation/widgets/catalog_search_bar.dart';
import 'package:flutter_testapp/features/catalog/presentation/widgets/category_filter_chips.dart';
import 'package:flutter_testapp/features/catalog/presentation/widgets/product_card.dart';
import 'package:flutter_testapp/features/catalog/presentation/widgets/product_shimmer_grid.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double textScale =
        (MediaQuery.textScalerOf(context).scale(14) / 14).clamp(1.0, 1.5);

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<CatalogBloc, CatalogState>(
          builder: (BuildContext context, CatalogState state) {
            return CustomScrollView(
              // Pre-cache slightly ahead of the viewport without eagerly mounting all 30 images.
              cacheExtent: 500,
              slivers: <Widget>[
                SliverAppBar(
                  floating: true,
                  snap: true,
                  toolbarHeight: 64 * textScale,
                  titleSpacing: AppSpacing.lg,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Curated Catalog',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.headlineSmall,
                      ),
                      if (state.status == CatalogStatus.success)
                        Text(
                          state.filteredProducts.length == 1
                              ? '1 item available'
                              : '${state.filteredProducts.length} items available',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  actions: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: IconButton(
                        tooltip: brightness == Brightness.dark
                            ? 'Switch to light mode'
                            : 'Switch to dark mode',
                        onPressed: () =>
                            context.read<ThemeCubit>().toggleTheme(brightness),
                        icon: Icon(
                          brightness == Brightness.dark
                              ? Icons.light_mode_outlined
                              : Icons.dark_mode_outlined,
                        ),
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.md,
                    ),
                    child: CatalogSearchBar(
                      query: state.searchQuery,
                      onChanged: (String query) {
                        context
                            .read<CatalogBloc>()
                            .add(CatalogSearchQueryChanged(query));
                      },
                      onCleared: () {
                        context
                            .read<CatalogBloc>()
                            .add(const CatalogSearchQueryChanged(''));
                      },
                    ),
                  ),
                ),
                if (state.categories.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: CategoryFilterChips(
                        categories: state.categories,
                        selectedCategory: state.selectedCategory,
                        onCategorySelected: (String? category) {
                          context
                              .read<CatalogBloc>()
                              .add(CatalogCategorySelected(category));
                        },
                      ),
                    ),
                  ),
                _buildBodySliver(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBodySliver(BuildContext context, CatalogState state) {
    final String stateKey;
    final Widget sliver;

    switch (state.status) {
      case CatalogStatus.initial:
      case CatalogStatus.loading:
        stateKey = 'catalog-loading';
        sliver = const ProductShimmerGrid();

      case CatalogStatus.failure:
        stateKey = 'catalog-error';
        final Failure failure = state.failure ?? const NetworkFailure();
        sliver = SliverFillRemaining(
          hasScrollBody: false,
          child: CatalogErrorState(
            message: failure.userMessage,
            onRetry: () {
              context.read<CatalogBloc>().add(const CatalogLoadRequested());
            },
          ),
        );

      case CatalogStatus.success:
        if (state.filteredProducts.isEmpty) {
          stateKey = 'catalog-empty';
          sliver = SliverFillRemaining(
            hasScrollBody: false,
            child: CatalogEmptyState(
              onResetFilters: () {
                context.read<CatalogBloc>().add(const CatalogFiltersReset());
              },
            ),
          );
        } else {
          stateKey = 'catalog-success';
          // Scale card proportions so 1.3x system font scaling never overflows.
          final double textScale =
              (MediaQuery.textScalerOf(context).scale(14) / 14).clamp(1.0, 1.5);
          final double cardAspectRatio = 0.64 / (1 + (textScale - 1) * 1.45);

          sliver = SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xs,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 240,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: cardAspectRatio,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  final Product product = state.filteredProducts[index];
                  return ProductCard(
                    product: product,
                    onTap: () => _openDetails(context, product),
                  );
                },
                childCount: state.filteredProducts.length,
              ),
            ),
          );
        }
    }

    return TweenAnimationBuilder<double>(
      key: ValueKey<String>(stateKey),
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double opacity, Widget? child) {
        return SliverOpacity(
          opacity: opacity,
          sliver: child,
        );
      },
      child: sliver,
    );
  }

  void _openDetails(BuildContext context, Product product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailsPage(product: product),
      ),
    );
  }
}
