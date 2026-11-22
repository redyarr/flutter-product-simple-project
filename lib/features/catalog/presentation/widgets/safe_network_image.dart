import 'package:flutter/material.dart';
import 'package:flutter_testapp/core/utils/url_validator.dart';

class SafeNetworkImage extends StatelessWidget {
  const SafeNetworkImage({
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.semanticsLabel,
    super.key,
  });

  final String imageUrl;
  final BoxFit fit;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (!UrlValidator.isValidHttpsUrl(imageUrl)) {
      return _ImageFallback(colorScheme: colorScheme);
    }

    return Image.network(
      imageUrl,
      fit: fit,
      semanticLabel: semanticsLabel,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
      frameBuilder: (
        BuildContext context,
        Widget child,
        int? frame,
        bool wasSynchronouslyLoaded,
      ) {
        // Render cached images immediately without flashing an entrance fade.
        if (wasSynchronouslyLoaded) {
          return child;
        }
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: child,
        );
      },
      errorBuilder: (
        BuildContext context,
        Object error,
        StackTrace? stackTrace,
      ) {
        return _ImageFallback(colorScheme: colorScheme);
      },
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: colorScheme.surfaceContainer),
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 32,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
