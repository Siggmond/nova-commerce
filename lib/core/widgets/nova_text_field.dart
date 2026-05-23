import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_tokens.dart';
import '../../app/theme/nova_tokens.dart';

enum NovaFieldDensity { compact, comfortable }

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
    this.density = NovaFieldDensity.compact,
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
  final NovaFieldDensity density;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    final isComfortable = density == NovaFieldDensity.comfortable;
    final contentPadding = isComfortable
        ? EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h)
        : EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h);
    final minHeight = isComfortable ? 56.h : AppHitTargets.comfortable;

    final textStyle = t.bodyMedium;
    final radius = BorderRadius.circular(NovaRadii.radius16);

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: TextField(
        controller: controller,
        enabled: enabled,
        obscureText: obscureText,
        style: textStyle,
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
          labelStyle: t.labelMedium,
          hintStyle: textStyle?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.6),
          ),
          prefixIcon: prefix,
          prefixIconConstraints: BoxConstraints(
            minWidth: AppHitTargets.comfortable,
            minHeight: AppHitTargets.comfortable,
          ),
          filled: true,
          fillColor: enabled
              ? NovaColors.sheet(cs)
              : cs.surfaceContainerHighest.withValues(alpha: 0.42),
          contentPadding: contentPadding,
          border: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: cs.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(
              color: cs.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(
              color: cs.outlineVariant.withValues(alpha: 0.38),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: cs.primary, width: 1.4),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: cs.error.withValues(alpha: 0.78)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: cs.error, width: 1.4),
          ),
        ),
      ),
    );
  }
}
