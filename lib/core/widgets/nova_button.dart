import 'package:flutter/material.dart';

import 'app_button.dart';

class NovaButton extends StatelessWidget {
  const NovaButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  }) : _variant = _NovaButtonVariant.primary;

  const NovaButton.tonal({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  }) : _variant = _NovaButtonVariant.tonal;

  const NovaButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  }) : _variant = _NovaButtonVariant.outlined;

  const NovaButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  }) : _variant = _NovaButtonVariant.text;

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final _NovaButtonVariant _variant;

  @override
  Widget build(BuildContext context) {
    switch (_variant) {
      case _NovaButtonVariant.primary:
        return AppButton.primary(
          label: label,
          onPressed: onPressed,
          isLoading: isLoading,
          icon: icon,
        );
      case _NovaButtonVariant.tonal:
        return AppButton.tonal(
          label: label,
          onPressed: onPressed,
          isLoading: isLoading,
          icon: icon,
        );
      case _NovaButtonVariant.outlined:
        return AppButton.outlined(
          label: label,
          onPressed: onPressed,
          isLoading: isLoading,
          icon: icon,
        );
      case _NovaButtonVariant.text:
        return AppButton.text(
          label: label,
          onPressed: onPressed,
          isLoading: isLoading,
          icon: icon,
        );
    }
  }
}

enum _NovaButtonVariant { primary, tonal, outlined, text }
