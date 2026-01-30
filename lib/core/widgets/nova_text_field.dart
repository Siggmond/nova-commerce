import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import '../theme/nova_tokens.dart';

class NovaTextField extends StatelessWidget {
  const NovaTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.focusNode,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.prefix,
  });

  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final String? errorText;
  final Widget? prefix;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      style: t.bodySmall,
      keyboardType: keyboardType,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: (_) => onSubmitted?.call(),
      decoration: InputDecoration(
        isDense: true,
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
        labelStyle: t.bodySmall,
        hintStyle: t.bodySmall?.copyWith(
          color: cs.onSurface.withValues(alpha: 0.6),
        ),
        prefixIcon: prefix,
        filled: true,
        fillColor: NovaColors.sheet(cs),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpace.md,
          vertical: AppSpace.xxs,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NovaRadii.radius16),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NovaRadii.radius16),
          borderSide: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NovaRadii.radius16),
          borderSide: BorderSide(color: cs.primary, width: 1.4),
        ),
      ),
    );
  }
}
