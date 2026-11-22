import 'package:flutter/material.dart';
import 'package:flutter_testapp/core/theme/app_colors.dart';
import 'package:flutter_testapp/core/theme/app_radius.dart';
import 'package:flutter_testapp/core/theme/app_spacing.dart';

class ProductShimmerGrid extends StatefulWidget {
  const ProductShimmerGrid({super.key});

  @override
  State<ProductShimmerGrid> createState() => _ProductShimmerGridState();
}

class _ProductShimmerGridState extends State<ProductShimmerGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _pulseAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double textScale =
        (MediaQuery.textScalerOf(context).scale(14) / 14).clamp(1.0, 1.5);
    final double cardAspectRatio = 0.64 / (1 + (textScale - 1) * 1.45);

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
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
            return AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (BuildContext context, Widget? child) {
                return _SkeletonCard(opacityFactor: _pulseAnimation.value);
              },
            );
          },
          childCount: 6,
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.opacityFactor});

  final double opacityFactor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color fill = Color.lerp(
          colorScheme.surfaceContainer,
          colorScheme.surfaceContainerHigh,
          opacityFactor,
        ) ??
        colorScheme.surfaceContainer;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1.15,
            child: ColoredBox(color: fill),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _SkeletonBar(width: 64, height: 10, color: fill),
                  const SizedBox(height: AppSpacing.xs),
                  _SkeletonBar(width: double.infinity, height: 14, color: fill),
                  const SizedBox(height: AppSpacing.xs),
                  _SkeletonBar(width: 110, height: 14, color: fill),
                  const Spacer(),
                  _SkeletonBar(width: 72, height: 18, color: fill),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.borderSm,
      ),
    );
  }
}
