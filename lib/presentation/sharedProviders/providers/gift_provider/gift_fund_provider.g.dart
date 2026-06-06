// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gift_fund_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Gift)
final giftProvider = GiftProvider._();

final class GiftProvider extends $NotifierProvider<Gift, GiftState> {
  GiftProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'giftProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$giftHash();

  @$internal
  @override
  Gift create() => Gift();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GiftState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GiftState>(value),
    );
  }
}

String _$giftHash() => r'5ef43cbaa957ea0dc0bc16a81f951118c18d496e';

abstract class _$Gift extends $Notifier<GiftState> {
  GiftState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<GiftState, GiftState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GiftState, GiftState>,
              GiftState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
