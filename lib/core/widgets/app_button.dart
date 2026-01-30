import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class AppButton extends StatelessWidget {
  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  }) : _variant = _AppButtonVariant.primary;

  const AppButton.tonal({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  }) : _variant = _AppButtonVariant.tonal;

  const AppButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  }) : _variant = _AppButtonVariant.text;

  const AppButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  }) : _variant = _AppButtonVariant.outlined;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final _AppButtonVariant _variant;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;
    final content = isLoading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : (icon == null
            ? Text(label)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon),
                  SizedBox(width: AppSpace.sm),
                  Text(label),
                ],
              ));

    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(
        Size.fromHeight(AppHitTargets.min),
      ),
      padding: WidgetStatePropertyAll(AppInsets.button),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
    );

    switch (_variant) {
      case _AppButtonVariant.primary:
        return FilledButton(
          onPressed: effectiveOnPressed,
          style: style,
          child: content,
        );
      case _AppButtonVariant.tonal:
        return FilledButton.tonal(
          onPressed: effectiveOnPressed,
          style: style,
          child: content,
        );
      case _AppButtonVariant.text:
        return TextButton(
          onPressed: effectiveOnPressed,
          style: style,
          child: content,
        );
      case _AppButtonVariant.outlined:
        return OutlinedButton(
          onPressed: effectiveOnPressed,
          style: style,
          child: content,
        );
    }
  }
}

enum _AppButtonVariant { primary, tonal, text, outlined }
