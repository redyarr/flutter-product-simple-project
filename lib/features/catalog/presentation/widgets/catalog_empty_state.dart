import 'package:flutter/material.dart';
import 'package:flutter_testapp/core/theme/app_colors.dart';
import 'package:flutter_testapp/core/theme/app_radius.dart';
import 'package:flutter_testapp/core/theme/app_spacing.dart';

class CatalogEmptyState extends StatelessWidget {
  const CatalogEmptyState({
    required this.onResetFilters,
    super.key,
  });

  final VoidCallback onResetFilters;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: AppRadius.borderXl,
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 30,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'No matching products',
                textAlign: TextAlign.center,
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Try adjusting your search keywords or switching back to all categories.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton.tonal(
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                ),
                onPressed: onResetFilters,
                child: const Text('Reset Filters'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
