import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:nova_commerce/app/config/app_env.dart';
import 'package:nova_commerce/app/router/app_routes.dart';
import 'package:nova_commerce/app/theme/app_tokens.dart';
import 'package:nova_commerce/core/perf/perf_markers.dart';
import 'package:nova_commerce/core/widgets/nova_app_bar.dart';
import 'package:nova_commerce/core/widgets/nova_button.dart';
import 'package:nova_commerce/core/widgets/nova_surface.dart';
import 'package:nova_commerce/core/widgets/nova_text_field.dart';
import 'package:nova_commerce/features/checkout/presentation/state/checkout_viewmodel.dart';
import 'package:nova_commerce/features/payments/payments.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';

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
    PerfMarkers.checkoutOpen();

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
    final l10n = AppLocalizations.of(context)!;
    final useNovaUi = AppEnv.enableNovaUi && AppEnv.enableNovaUiCheckout;
    final vm = ref.read(checkoutViewModelProvider.notifier);

    ref.listen<int>(checkoutViewModelProvider.select((s) => s.eventId), (
      previous,
      next,
    ) {
      final snapshot = ref.read(checkoutViewModelProvider);
      final event = snapshot.event;
      final summary = snapshot.summary;
      if (event is CheckoutShowSnack) {
        final message = switch (event.key) {
          CheckoutSnackKey.cartEmpty => l10n.checkoutCartEmpty,
          CheckoutSnackKey.signInRequired => l10n.checkoutSignInRequired,
          CheckoutSnackKey.somethingWentWrongTryAgain =>
            l10n.commonSomethingWentWrongTryAgain,
          null => event.message ?? '',
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(AppSpace.xl),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            content: Text(message),
          ),
        );
      } else if (event is CheckoutGoToSignIn) {
        context.push(AppRoutes.signIn);
      } else if (event is CheckoutGoToPayment) {
        context.push(
          AppRoutes.payment,
          extra: PaymentFlowArgs(
            summary: summary,
            uid: event.uid,
            deviceId: event.deviceId,
            shipping: event.shipping,
          ),
        );
      } else if (event is CheckoutGoToSuccess) {
        context.go(
          '${AppRoutes.orderSuccess}/${event.orderId}',
          extra: summary,
        );
      }
    });

    return _CheckoutPopScope(
      child: Scaffold(
        key: const Key('checkout_screen_scaffold'),
        appBar: useNovaUi
            ? NovaAppBar(titleText: l10n.checkoutTitle)
            : AppBar(title: Text(l10n.checkoutTitle)),
        body: ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpace.xl,
            AppSpace.md,
            AppSpace.xl,
            MediaQuery.of(context).viewInsets.bottom + AppSpace.section,
          ),
          children: [
            Text(
              l10n.checkoutShippingTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.12,
              ),
            ),
            SizedBox(height: AppSpace.sm),
            Text(
              l10n.checkoutShippingSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.75),
                height: 1.3,
              ),
            ),
            SizedBox(height: AppSpace.xl),
            _CheckoutFormCard(
              useNovaUi: useNovaUi,
              fullName: _fullName,
              phone: _phone,
              address: _address,
              city: _city,
              stateRegion: _state,
              postalCode: _postalCode,
              country: _country,
              fullNameFocus: _fullNameFocus,
              phoneFocus: _phoneFocus,
              addressFocus: _addressFocus,
              cityFocus: _cityFocus,
              stateFocus: _stateFocus,
              postalFocus: _postalFocus,
              countryFocus: _countryFocus,
              onTapPhoneCountry: () => _showCountryPicker(context, vm),
            ),
            SizedBox(height: AppSpace.md),
            _CheckoutSummaryCard(useNovaUi: useNovaUi),
            SizedBox(height: AppSpace.md),
            _CheckoutActions(useNovaUi: useNovaUi),
          ],
        ),
      ),
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

class _CheckoutPopScope extends ConsumerWidget {
  const _CheckoutPopScope({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canPop = !ref.watch(
      checkoutActionViewProvider.select((s) => s.isSubmitting),
    );
    return PopScope(canPop: canPop, child: child);
  }
}

class _CheckoutFormCard extends ConsumerWidget {
  const _CheckoutFormCard({
    required this.useNovaUi,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.city,
    required this.stateRegion,
    required this.postalCode,
    required this.country,
    required this.fullNameFocus,
    required this.phoneFocus,
    required this.addressFocus,
    required this.cityFocus,
    required this.stateFocus,
    required this.postalFocus,
    required this.countryFocus,
    required this.onTapPhoneCountry,
  });

  final bool useNovaUi;
  final TextEditingController fullName;
  final TextEditingController phone;
  final TextEditingController address;
  final TextEditingController city;
  final TextEditingController stateRegion;
  final TextEditingController postalCode;
  final TextEditingController country;
  final FocusNode fullNameFocus;
  final FocusNode phoneFocus;
  final FocusNode addressFocus;
  final FocusNode cityFocus;
  final FocusNode stateFocus;
  final FocusNode postalFocus;
  final FocusNode countryFocus;
  final VoidCallback onTapPhoneCountry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(checkoutFormViewProvider);
    final vm = ref.read(checkoutViewModelProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    _syncController(fullName, form.fullName);
    _syncController(phone, form.phone);
    _syncController(address, form.address);
    _syncController(city, form.city);
    _syncController(stateRegion, form.state);
    _syncController(postalCode, form.postalCode);
    _syncController(country, form.country);

    final cardChild = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.checkoutDeliveryTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        SizedBox(height: AppSpace.md),
        _Field(
          useNovaUi: useNovaUi,
          label: l10n.checkoutFullNameLabel,
          controller: fullName,
          focusNode: fullNameFocus,
          errorText: _mapFieldError(l10n, form.fullNameError),
          onChanged: vm.setFullName,
          textInputAction: TextInputAction.next,
          onSubmitted: () => phoneFocus.requestFocus(),
        ),
        SizedBox(height: AppSpace.sm),
        _Field(
          useNovaUi: useNovaUi,
          label: l10n.checkoutPhoneLabel,
          controller: phone,
          focusNode: phoneFocus,
          keyboardType: TextInputType.phone,
          errorText: _mapFieldError(l10n, form.phoneError),
          onChanged: vm.setPhone,
          textInputAction: TextInputAction.next,
          onSubmitted: () => addressFocus.requestFocus(),
          prefix: _PhoneCountryPrefix(
            dialCode: form.phoneDialCode,
            onTap: onTapPhoneCountry,
          ),
        ),
        SizedBox(height: AppSpace.sm),
        _Field(
          useNovaUi: useNovaUi,
          label: l10n.checkoutAddressLabel,
          controller: address,
          focusNode: addressFocus,
          errorText: _mapFieldError(l10n, form.addressError),
          onChanged: vm.setAddress,
          textInputAction: TextInputAction.next,
          onSubmitted: () => cityFocus.requestFocus(),
        ),
        if (form.placesConfigured && !form.manualEntryOnly)
          _AddressSuggestions(
            isLoading: form.isFetchingSuggestions,
            suggestions: form.addressSuggestions,
            showManualOption: true,
            showUnavailableHint:
                form.placesUnavailable || !form.placesAvailable,
            onSelected: vm.selectSuggestion,
            onManualEntry: vm.markManualEntry,
          ),
        SizedBox(height: AppSpace.sm),
        Row(
          children: [
            Expanded(
              child: _Field(
                useNovaUi: useNovaUi,
                label: l10n.checkoutCityLabel,
                controller: city,
                focusNode: cityFocus,
                errorText: _mapFieldError(l10n, form.cityError),
                onChanged: vm.setCity,
                textInputAction: TextInputAction.next,
                onSubmitted: () => stateFocus.requestFocus(),
              ),
            ),
            SizedBox(width: AppSpace.sm),
            Expanded(
              child: _Field(
                useNovaUi: useNovaUi,
                label: l10n.checkoutStateLabel,
                controller: stateRegion,
                focusNode: stateFocus,
                errorText: _mapFieldError(l10n, form.stateError),
                onChanged: vm.setStateRegion,
                textInputAction: TextInputAction.next,
                onSubmitted: () => postalFocus.requestFocus(),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpace.sm),
        Row(
          children: [
            Expanded(
              child: _Field(
                useNovaUi: useNovaUi,
                label: l10n.checkoutPostalCodeLabel,
                controller: postalCode,
                focusNode: postalFocus,
                errorText: _mapFieldError(l10n, form.postalCodeError),
                onChanged: vm.setPostalCode,
                textInputAction: TextInputAction.next,
                onSubmitted: () => countryFocus.requestFocus(),
              ),
            ),
            SizedBox(width: AppSpace.sm),
            Expanded(
              child: _Field(
                useNovaUi: useNovaUi,
                label: l10n.checkoutCountryLabel,
                controller: country,
                focusNode: countryFocus,
                errorText: _mapFieldError(l10n, form.countryError),
                onChanged: vm.setCountry,
                textInputAction: TextInputAction.done,
                onSubmitted: () => FocusScope.of(context).unfocus(),
              ),
            ),
          ],
        ),
      ],
    );

    if (useNovaUi) {
      return NovaSurface(
        padding: AppInsets.card,
        borderRadius: AppRadii.lg,
        child: cardChild,
      );
    }
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Padding(padding: AppInsets.card, child: cardChild),
    );
  }
}

class _CheckoutSummaryCard extends ConsumerWidget {
  const _CheckoutSummaryCard({required this.useNovaUi});

  final bool useNovaUi;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(checkoutCartSummaryProvider);
    final l10n = AppLocalizations.of(context)!;
    final currency = summary.currency.toUpperCase();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.checkoutSubtotalLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
            ),
            Text(
              '$currency ${summary.subtotal.toStringAsFixed(0)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpace.md),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.checkoutShippingFeeLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.76),
                ),
              ),
            ),
            Text(
              summary.shippingFee <= 0
                  ? l10n.checkoutFreeShipping
                  : '$currency ${summary.shippingFee.toStringAsFixed(0)}',
              style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        SizedBox(height: AppSpace.md),
        Container(
          padding: AppInsets.cardTight,
          decoration: BoxDecoration(
            color: cs.primaryContainer.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.checkoutTotalLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
              ),
              Text(
                '$currency ${summary.total.toStringAsFixed(0)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (useNovaUi) {
      return NovaSurface(
        padding: AppInsets.card,
        borderRadius: AppRadii.lg,
        child: content,
      );
    }
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Padding(padding: AppInsets.card, child: content),
    );
  }
}

class _CheckoutActions extends ConsumerWidget {
  const _CheckoutActions({required this.useNovaUi});

  final bool useNovaUi;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final action = ref.watch(checkoutActionViewProvider);
    final l10n = AppLocalizations.of(context)!;
    final vm = ref.read(checkoutViewModelProvider.notifier);
    final canSubmit =
        !action.isSubmitting &&
        !action.isRecalculatingSummary &&
        action.hasSelectedItems &&
        action.isSignedIn;

    return Column(
      children: [
        if (!action.hasSelectedItems || !action.isSignedIn) ...[
          _CheckoutHint(
            message: !action.hasSelectedItems
                ? l10n.checkoutHintSelectItems
                : l10n.checkoutHintSignIn,
            useNovaUi: useNovaUi,
          ),
          SizedBox(height: AppSpace.md),
        ],
        SafeArea(
          top: false,
          child: useNovaUi
              ? SizedBox(
                  width: double.infinity,
                  height: AppHitTargets.comfortable,
                  child: NovaButton.primary(
                    onPressed: canSubmit ? vm.submit : null,
                    label: action.isSubmitting
                        ? l10n.checkoutPlacingOrder
                        : l10n.checkoutPlaceOrder,
                    isLoading: action.isSubmitting,
                  ),
                )
              : SizedBox(
                  width: double.infinity,
                  height: AppHitTargets.comfortable,
                  child: FilledButton(
                    onPressed: canSubmit ? vm.submit : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (action.isSubmitting) ...[
                          SizedBox(
                            width: 16.r,
                            height: 16.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: AppSpace.sm),
                        ],
                        Text(
                          action.isSubmitting
                              ? l10n.checkoutPlacingOrder
                              : l10n.checkoutPlaceOrder,
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

String? _mapFieldError(AppLocalizations l10n, CheckoutFieldErrorKey? key) {
  return switch (key) {
    CheckoutFieldErrorKey.requiredField => l10n.commonRequired,
    CheckoutFieldErrorKey.invalidPhone => l10n.checkoutInvalidPhone,
    null => null,
  };
}

void _syncController(TextEditingController controller, String value) {
  if (controller.text == value) return;
  controller.value = TextEditingValue(
    text: value,
    selection: TextSelection.collapsed(offset: value.length),
  );
}

class _CheckoutHint extends StatelessWidget {
  const _CheckoutHint({required this.message, required this.useNovaUi});

  final String message;
  final bool useNovaUi;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final child = Row(
      children: [
        Container(
          width: AppHitTargets.min,
          height: AppHitTargets.min,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Icon(
            Icons.info_outline,
            size: 18.r,
            color: cs.onSurfaceVariant,
          ),
        ),
        SizedBox(width: AppSpace.md),
        Expanded(
          child: Text(
            message,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.22,
            ),
          ),
        ),
      ],
    );

    if (useNovaUi) {
      return NovaSurface(
        padding: AppInsets.cardTight,
        borderRadius: AppRadii.lg,
        child: child,
      );
    }

    return Container(
      padding: AppInsets.cardTight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.36),
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
        padding: EdgeInsets.symmetric(
          horizontal: AppSpace.md,
          vertical: AppSpace.md,
        ),
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
    final l10n = AppLocalizations.of(context)!;
    if (isLoading) {
      return Padding(
        padding: EdgeInsets.only(top: AppSpace.sm),
        child: Row(
          children: [
            SizedBox(
              width: 14.r,
              height: 14.r,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: AppSpace.sm),
            Text(
              l10n.checkoutAddressSearching,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: AppSpace.sm),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount:
            suggestions.length +
            (showUnavailableHint ? 1 : 0) +
            (showManualOption ? 1 : 0),
        itemBuilder: (context, index) {
          var cursor = 0;

          if (showUnavailableHint) {
            if (index == cursor) {
              return Padding(
                padding: EdgeInsets.only(bottom: AppSpace.xs),
                child: Text(
                  l10n.checkoutAddressSuggestionsUnavailable,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              );
            }
            cursor += 1;
          }

          final suggestionsEnd = cursor + suggestions.length;
          if (index < suggestionsEnd) {
            final suggestion = suggestions[index - cursor];
            return ListTile(
              dense: true,
              minVerticalPadding: AppSpace.xs,
              contentPadding: EdgeInsets.symmetric(horizontal: AppSpace.xs),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              title: Text(suggestion.description),
              onTap: () => onSelected(suggestion),
            );
          }

          return Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onManualEntry,
              child: Text(l10n.checkoutUseManualEntry),
            ),
          );
        },
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
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
