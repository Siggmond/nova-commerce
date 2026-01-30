import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_env.dart';
import '../../../core/config/app_routes.dart';
import '../../../core/widgets/nova_app_bar.dart';
import '../../../core/widgets/nova_button.dart';
import '../../../core/widgets/nova_surface.dart';
import '../../../core/widgets/nova_text_field.dart';
import '../domain/checkout_cart_summary.dart';
import 'checkout_viewmodel.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _postalCode = TextEditingController();
  final _country = TextEditingController(text: '');

  final _fullNameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _cityFocus = FocusNode();
  final _stateFocus = FocusNode();
  final _postalFocus = FocusNode();
  final _countryFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final vm = ref.read(checkoutViewModelProvider.notifier);
      vm.reset();
      await vm.hydrateAddress();

      final s = ref.read(checkoutViewModelProvider);
      _fullName.text = s.fullName;
      _phone.text = s.phone;
      _address.text = s.address;
      _city.text = s.city;
      _state.text = s.state;
      _postalCode.text = s.postalCode;
      _country.text = s.country;
    });
  }

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _address.dispose();
    _city.dispose();
    _state.dispose();
    _postalCode.dispose();
    _country.dispose();
    _fullNameFocus.dispose();
    _phoneFocus.dispose();
    _addressFocus.dispose();
    _cityFocus.dispose();
    _stateFocus.dispose();
    _postalFocus.dispose();
    _countryFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final useNovaUi = AppEnv.enableNovaUi && AppEnv.enableNovaUiCheckout;
    final summary = ref.watch(checkoutCartSummaryProvider);
    final state = ref.watch(checkoutViewModelProvider);
    final vm = ref.read(checkoutViewModelProvider.notifier);

    ref.listen<int>(checkoutViewModelProvider.select((s) => s.eventId), (
      previous,
      next,
    ) {
      final event = ref.read(checkoutViewModelProvider).event;
      if (event is CheckoutShowSnack) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(event.message)));
      } else if (event is CheckoutGoToSignIn) {
        context.push(AppRoutes.signIn);
      } else if (event is CheckoutGoToSuccess) {
        context.go(
          '${AppRoutes.orderSuccess}/${event.orderId}',
          extra: summary,
        );
      }
    });

    return PopScope(
      canPop: !state.isSubmitting,
      child: Scaffold(
        appBar: useNovaUi
            ? NovaAppBar(titleText: 'Checkout')
            : AppBar(title: const Text('Checkout')),
        body: ListView(
          padding: EdgeInsets.fromLTRB(
            16.w,
            12.h,
            16.w,
            MediaQuery.of(context).viewInsets.bottom + 20.h,
          ),
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
            (useNovaUi
                ? NovaSurface(
                    padding: EdgeInsets.all(14.r),
                    child: _deliveryForm(context, state, vm, useNovaUi),
                  )
                : Card(
                    child: Padding(
                      padding: EdgeInsets.all(14.r),
                      child: _deliveryForm(context, state, vm, useNovaUi),
                    ),
                  )),
            SizedBox(height: 12.h),
            (useNovaUi
                ? NovaSurface(
                    padding: EdgeInsets.all(14.r),
                    child: _subtotalRow(context, summary),
                  )
                : Card(
                    child: Padding(
                      padding: EdgeInsets.all(14.r),
                      child: _subtotalRow(context, summary),
                    ),
                  )),
            if (!summary.hasItems || !state.isSignedIn) ...[
              SizedBox(height: 12.h),
              _CheckoutHint(
                message: !summary.hasItems
                    ? 'Select items in cart to continue'
                    : 'Sign in to place your order',
                useNovaUi: useNovaUi,
              ),
            ],
            SizedBox(height: 12.h),
            SafeArea(
              top: false,
              child: useNovaUi
                  ? SizedBox(
                      width: double.infinity,
                      child: NovaButton.primary(
                        onPressed: state.isSubmitting || !summary.hasItems
                            ? null
                            : () => vm.submit(),
                        label: state.isSubmitting
                            ? 'Placing order…'
                            : 'Place order',
                        isLoading: state.isSubmitting,
                      ),
                    )
                  : FilledButton(
                      onPressed: state.isSubmitting || !summary.hasItems
                          ? null
                          : () => vm.submit(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (state.isSubmitting) ...[
                            SizedBox(
                              width: 16.r,
                              height: 16.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 10.w),
                          ],
                          Text(
                            state.isSubmitting
                                ? 'Placing order…'
                                : 'Place order',
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deliveryForm(
    BuildContext context,
    CheckoutState state,
    CheckoutViewModel vm,
    bool useNovaUi,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 12.h),
        _Field(
          useNovaUi: useNovaUi,
          label: 'Full name',
          controller: _fullName,
          focusNode: _fullNameFocus,
          errorText: state.fullNameError,
          onChanged: vm.setFullName,
          textInputAction: TextInputAction.next,
          onSubmitted: () => _phoneFocus.requestFocus(),
        ),
        SizedBox(height: 10.h),
        _Field(
          useNovaUi: useNovaUi,
          label: 'Phone',
          controller: _phone,
          focusNode: _phoneFocus,
          keyboardType: TextInputType.phone,
          errorText: state.phoneError,
          onChanged: vm.setPhone,
          textInputAction: TextInputAction.next,
          onSubmitted: () => _addressFocus.requestFocus(),
          prefix: _PhoneCountryPrefix(
            dialCode: state.phoneDialCode,
            onTap: () => _showCountryPicker(context, vm),
          ),
        ),
        SizedBox(height: 10.h),
        _Field(
          useNovaUi: useNovaUi,
          label: 'Address',
          controller: _address,
          focusNode: _addressFocus,
          errorText: state.addressError,
          onChanged: vm.setAddress,
          textInputAction: TextInputAction.next,
          onSubmitted: () => _cityFocus.requestFocus(),
        ),
        if (state.placesConfigured && !state.manualEntryOnly)
          _AddressSuggestions(
            isLoading: state.isFetchingSuggestions,
            suggestions: state.addressSuggestions,
            showManualOption: true,
            showUnavailableHint:
                state.placesUnavailable || !state.placesAvailable,
            onSelected: vm.selectSuggestion,
            onManualEntry: vm.markManualEntry,
          ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _Field(
                useNovaUi: useNovaUi,
                label: 'City',
                controller: _city,
                focusNode: _cityFocus,
                errorText: state.cityError,
                onChanged: vm.setCity,
                textInputAction: TextInputAction.next,
                onSubmitted: () => _stateFocus.requestFocus(),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _Field(
                useNovaUi: useNovaUi,
                label: 'State/Region',
                controller: _state,
                focusNode: _stateFocus,
                errorText: state.stateError,
                onChanged: vm.setStateRegion,
                textInputAction: TextInputAction.next,
                onSubmitted: () => _postalFocus.requestFocus(),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _Field(
                useNovaUi: useNovaUi,
                label: 'Postal code',
                controller: _postalCode,
                focusNode: _postalFocus,
                errorText: state.postalCodeError,
                onChanged: vm.setPostalCode,
                textInputAction: TextInputAction.next,
                onSubmitted: () => _countryFocus.requestFocus(),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _Field(
                useNovaUi: useNovaUi,
                label: 'Country',
                controller: _country,
                focusNode: _countryFocus,
                errorText: state.countryError,
                onChanged: vm.setCountry,
                textInputAction: TextInputAction.done,
                onSubmitted: () => FocusScope.of(context).unfocus(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _subtotalRow(BuildContext context, CheckoutCartSummary summary) {
    final currency = summary.currency.toUpperCase();
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Subtotal',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              '$currency ${summary.subtotal.toStringAsFixed(0)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: Text(
                'Shipping',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Text(
              'Free shipping',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Divider(height: 1.h),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: Text(
                'Total',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            Text(
              '$currency ${summary.total.toStringAsFixed(0)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ],
    );
  }

  void _showCountryPicker(BuildContext context, CheckoutViewModel vm) {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (country) {
        final dialCode = '+${country.phoneCode}';
        vm.setPhoneRegionInfo(
          regionCode: country.countryCode,
          dialCode: dialCode,
        );
      },
    );
  }
}

class _CheckoutHint extends StatelessWidget {
  const _CheckoutHint({required this.message, required this.useNovaUi});

  final String message;
  final bool useNovaUi;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      children: [
        Icon(
          Icons.info_outline,
          size: 18.r,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );

    if (useNovaUi) {
      return NovaSurface(padding: EdgeInsets.all(12.r), child: child);
    }

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: child,
    );
  }
}

class _PhoneCountryPrefix extends StatelessWidget {
  const _PhoneCountryPrefix({required this.dialCode, required this.onTap});

  final String dialCode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        child: Text(
          dialCode,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _AddressSuggestions extends StatelessWidget {
  const _AddressSuggestions({
    required this.isLoading,
    required this.suggestions,
    required this.showManualOption,
    required this.showUnavailableHint,
    required this.onSelected,
    required this.onManualEntry,
  });

  final bool isLoading;
  final List<PlaceSuggestion> suggestions;
  final bool showManualOption;
  final bool showUnavailableHint;
  final ValueChanged<PlaceSuggestion> onSelected;
  final VoidCallback onManualEntry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Padding(
        padding: EdgeInsets.only(top: 8.h),
        child: Row(
          children: [
            SizedBox(
              width: 16.r,
              height: 16.r,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8.w),
            Text('Searching…', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showUnavailableHint)
            Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Text(
                'Address suggestions unavailable — you can enter manually.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ...suggestions.map(
            (s) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(s.description),
              onTap: () => onSelected(s),
            ),
          ),
          if (showManualOption)
            TextButton(
              onPressed: onManualEntry,
              child: const Text('Use manual entry'),
            ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.useNovaUi,
    required this.label,
    required this.controller,
    this.onChanged,
    this.errorText,
    this.keyboardType,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.prefix,
  });

  final bool useNovaUi;
  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmitted;
  final Widget? prefix;

  @override
  Widget build(BuildContext context) {
    if (useNovaUi) {
      return NovaTextField(
        controller: controller,
        labelText: label,
        keyboardType: keyboardType,
        focusNode: focusNode,
        textInputAction: textInputAction,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        errorText: errorText,
        prefix: prefix,
      );
    }

    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onFieldSubmitted: (_) => onSubmitted?.call(),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        errorText: errorText,
        prefixIcon: prefix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
