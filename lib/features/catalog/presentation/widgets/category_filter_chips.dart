import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_testapp/core/theme/app_colors.dart';
import 'package:flutter_testapp/core/theme/app_radius.dart';
import 'package:flutter_testapp/core/theme/app_spacing.dart';

class CategoryFilterChips extends StatelessWidget {
  const CategoryFilterChips({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    super.key,
  });

  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final List<String?> chipValues = <String?>[null, ...categories];
    final double textScale =
        (MediaQuery.textScalerOf(context).scale(14) / 14).clamp(1.0, 1.5);

    return SizedBox(
      height: 42 * textScale,
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (Rect bounds) {
          final double fadeStart = bounds.width > AppSpacing.xl
              ? (bounds.width - AppSpacing.xl) / bounds.width
              : 0.0;
          return LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: <Color>[
              colorScheme.onSurface,
              colorScheme.onSurface,
              colorScheme.onSurface.withValues(alpha: 0),
            ],
            stops: <double>[0.0, fadeStart, 1.0],
          ).createShader(bounds);
        },
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          itemCount: chipValues.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (BuildContext context, int index) {
            final String? category = chipValues[index];
            final bool isSelected = category == selectedCategory;
            final String label =
                category == null ? 'All' : _formatCategoryLabel(category);

            return _CategoryPill(
              label: label,
              isSelected: isSelected,
              onTap: () {
                HapticFeedback.selectionClick();
                onCategorySelected(category);
              },
            );
          },
        ),
      ),
    );
  }

  static String _formatCategoryLabel(String raw) {
    final List<String> words = raw.split(RegExp(r'[-_\s]+'));
    final List<String> formatted = <String>[];
    for (final String word in words) {
      if (word.isEmpty) {
        continue;
      }
      final String first = word.substring(0, 1).toUpperCase();
      final String rest = word.length > 1 ? word.substring(1) : '';
      formatted.add('$first$rest');
    }
    return formatted.isEmpty ? raw : formatted.join(' ');
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '$label category filter',
      child: Material(
        color: colorScheme.surface.withValues(alpha: 0),
        borderRadius: AppRadius.borderXl,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderXl,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerLowest,
              borderRadius: AppRadius.borderXl,
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelLarge?.copyWith(
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
