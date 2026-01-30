import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nova_commerce/core/widgets/app_button.dart';

void main() {
  final file = File('test/goldens/app_button.png');

  testWidgets('AppButton golden', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 220));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                AppButton.primary(label: 'Primary', onPressed: null),
                SizedBox(height: 12),
                AppButton.tonal(label: 'Tonal', onPressed: null),
                SizedBox(height: 12),
                AppButton.outlined(label: 'Outlined', onPressed: null),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/app_button.png'),
    );
  }, skip: !file.existsSync());
}
