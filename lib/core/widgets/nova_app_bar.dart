import 'package:flutter/material.dart';

class NovaAppBar extends AppBar {
  NovaAppBar({
    super.key,
    String? titleText,
    Widget? title,
    super.actions,
    super.leading,
  }) : super(title: title ?? Text(titleText ?? ''), elevation: 0);
}
