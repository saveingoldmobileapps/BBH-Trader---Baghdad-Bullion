// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_option_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PaymentOption)
final paymentOptionProvider = PaymentOptionProvider._();

final class PaymentOptionProvider
    extends $NotifierProvider<PaymentOption, PaymentOptionState> {
  PaymentOptionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentOptionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentOptionHash();

  @$internal
  @override
  PaymentOption create() => PaymentOption();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaymentOptionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaymentOptionState>(value),
    );
  }
}

String _$paymentOptionHash() => r'7cc191ca1b1c8aa8321a9912c1f1fa0085c97c7f';

abstract class _$PaymentOption extends $Notifier<PaymentOptionState> {
  PaymentOptionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PaymentOptionState, PaymentOptionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PaymentOptionState, PaymentOptionState>,
              PaymentOptionState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
