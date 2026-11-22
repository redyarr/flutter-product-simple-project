import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_testapp/core/constants/api_constants.dart';
import 'package:flutter_testapp/core/theme/app_radius.dart';
import 'package:flutter_testapp/core/theme/app_spacing.dart';

class CatalogSearchBar extends StatefulWidget {
  const CatalogSearchBar({
    required this.query,
    required this.onChanged,
    required this.onCleared,
    super.key,
  });

  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onCleared;

  @override
  State<CatalogSearchBar> createState() => _CatalogSearchBarState();
}

class _CatalogSearchBarState extends State<CatalogSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(covariant CatalogSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query.isEmpty && _controller.text.isNotEmpty) {
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return TextField(
      controller: _controller,
      onChanged: (String value) {
        setState(() {});
        widget.onChanged(value);
      },
      textInputAction: TextInputAction.search,
      style: textTheme.bodyLarge,
      inputFormatters: <TextInputFormatter>[
        LengthLimitingTextInputFormatter(ApiConstants.maxSearchLength),
      ],
      decoration: InputDecoration(
        hintText: 'Search products, brands, or categories...',
        prefixIcon: Icon(
          Icons.search_rounded,
          color: colorScheme.onSurfaceVariant,
          size: 20,
        ),
        suffixIcon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
          child: _controller.text.isNotEmpty
              ? IconButton(
                  key: const ValueKey<String>('clear-search-button'),
                  tooltip: 'Clear search',
                  onPressed: () {
                    _controller.clear();
                    setState(() {});
                    widget.onCleared();
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                )
              : const SizedBox.shrink(
                  key: ValueKey<String>('empty-clear-button'),
                ),
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.borderLg,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }
}
