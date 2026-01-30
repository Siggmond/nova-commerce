import 'package:flutter/material.dart';

class NovaAppBar extends AppBar {
  NovaAppBar({
    super.key,
    required String titleText,
    super.actions,
    super.leading,
  }) : super(title: Text(titleText), elevation: 0);
}
