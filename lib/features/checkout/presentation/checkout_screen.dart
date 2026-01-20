import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_env.dart';
import '../../../core/config/app_routes.dart';
import '../../../data/datasources/device_id_datasource.dart';
import '../../cart/presentation/cart_viewmodel.dart';
import '../../../domain/entities/cart_item.dart';

class _OutOfStockException implements Exception {
  const _OutOfStockException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _country = TextEditingController(text: '');

  bool _submitting = false;

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _address.dispose();
    _city.dispose();
    _country.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final items = ref.read(cartViewModelProvider);
    if (items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Your cart is empty.')));
      return;
    }

    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    if (uid == null || uid.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to continue.')),
      );
      context.push(AppRoutes.signIn);
      return;
    }

    setState(() => _submitting = true);
    try {
      final subtotal = items.fold<double>(
        0,
        (totalSoFar, i) => totalSoFar + i.total,
      );
      const shippingFee = 0.0;
      final total = subtotal + shippingFee;
      final currency = items.first.product.currency;

      final deviceId = await DeviceIdDataSource().getOrCreate();

      final orderId = AppEnv.useFakeRepos
          ? 'demo_${DateTime.now().millisecondsSinceEpoch}'
          : await FirebaseFirestore.instance.runTransaction<String>((tx) async {
              final db = FirebaseFirestore.instance;
              final orderRef = db.collection('orders').doc();

              final byProductId = <String, List<CartItem>>{};
              for (final item in items) {
                byProductId
                    .putIfAbsent(item.product.id, () => <CartItem>[])
                    .add(item);
              }

              for (final entry in byProductId.entries) {
                final productId = entry.key;
                final productRef = db.collection('products').doc(productId);
                final snap = await tx.get(productRef);
                final data = snap.data();
                if (!snap.exists || data == null) {
                  throw _OutOfStockException(
                    'A product is no longer available.',
                  );
                }

                final title = (data['title'] as String?) ?? 'Product';
                final variantsRaw = data['variants'];
                if (variantsRaw is! List) {
                  throw _OutOfStockException(
                    '$title is not available in the selected variant.',
                  );
                }

                final variants = variantsRaw
                    .whereType<Map>()
                    .map(
                      (m) =>
                          Map<String, dynamic>.from(m.cast<String, dynamic>()),
                    )
                    .toList(growable: false);

                final updated = variants
                    .map((v) => Map<String, dynamic>.from(v))
                    .toList(growable: false);

                for (final item in entry.value) {
                  final color = item.selectedColor.trim();
                  final size = item.selectedSize.trim();
                  final qty = item.quantity;

                  final idx = updated.indexWhere((v) {
                    final c = (v['color'] as String?) ?? '';
                    final s = (v['size'] as String?) ?? '';
                    return c.trim() == color && s.trim() == size;
                  });

                  if (idx < 0) {
                    throw _OutOfStockException(
                      '$title ($color • $size) is no longer available.',
                    );
                  }

                  final currentStock =
                      (updated[idx]['stock'] as num?)?.toInt() ?? 0;
                  if (currentStock < qty) {
                    throw _OutOfStockException(
                      '$title ($color • $size) has only $currentStock left.',
                    );
                  }

                  updated[idx]['stock'] = currentStock - qty;
                }

                tx.update(productRef, {
                  'variants': updated,
                  'updatedAt': FieldValue.serverTimestamp(),
                });
              }

              final payload = {
                'uid': uid,
                'deviceId': deviceId,
                'status': 'placed',
                'currency': currency,
                'subtotal': subtotal,
                'shippingFee': shippingFee,
                'total': total,
                'shipping': {
                  'fullName': _fullName.text.trim(),
                  'phone': _phone.text.trim(),
                  'address': _address.text.trim(),
                  'city': _city.text.trim(),
                  'country': _country.text.trim(),
                },
                'items': items
                    .map(
                      (i) => {
                        'productId': i.product.id,
                        'title': i.product.title,
                        'price': i.product.price,
                        'quantity': i.quantity,
                        'selectedColor': i.selectedColor,
                        'selectedSize': i.selectedSize,
                      },
                    )
                    .toList(growable: false),
                'createdAt': FieldValue.serverTimestamp(),
                'updatedAt': FieldValue.serverTimestamp(),
              };
              tx.set(orderRef, payload);

              return orderRef.id;
            });

      ref.read(cartViewModelProvider.notifier).clear();

      if (!mounted) return;
      context.go('${AppRoutes.orderSuccess}/$orderId');
    } on _OutOfStockException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(cartViewModelProvider);
    final currency = items.isNotEmpty ? items.first.product.currency : 'USD';
    final subtotal = items.fold<double>(
      0,
      (totalSoFar, i) => totalSoFar + i.total,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
          children: [
            Text(
              'Shipping',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 8.h),
            Text(
              'Enter delivery details to place your order.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
            SizedBox(height: 16.h),
            Card(
              child: Padding(
                padding: EdgeInsets.all(14.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _Field(
                      label: 'Full name',
                      controller: _fullName,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    SizedBox(height: 10.h),
                    _Field(
                      label: 'Phone',
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    SizedBox(height: 10.h),
                    _Field(
                      label: 'Address',
                      controller: _address,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Expanded(
                          child: _Field(
                            label: 'City',
                            controller: _city,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _Field(
                            label: 'Country',
                            controller: _country,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Card(
              child: Padding(
                padding: EdgeInsets.all(14.r),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Subtotal',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text(
                      '${currency.toUpperCase()} ${subtotal.toStringAsFixed(0)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
            SafeArea(
              top: false,
              child: FilledButton(
                onPressed: _submitting || items.isEmpty ? null : _submit,
                child: Text(_submitting ? 'Placing order…' : 'Place order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
