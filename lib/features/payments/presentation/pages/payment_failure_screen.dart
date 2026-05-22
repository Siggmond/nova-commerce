import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:nova_commerce/gen_l10n/app_localizations.dart';

class PaymentFailureScreen extends StatelessWidget {
  const PaymentFailureScreen({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.paymentsFailureTitle)),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              kDebugMode && message.trim().isNotEmpty
                  ? message
                  : t.paymentsFailureBody,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.pop(),
                child: Text(t.commonBack),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
