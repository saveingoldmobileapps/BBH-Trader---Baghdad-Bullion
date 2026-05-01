// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trade_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Trade)
final tradeProvider = TradeProvider._();

final class TradeProvider extends $NotifierProvider<Trade, TradeState> {
  TradeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tradeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tradeHash();

  @$internal
  @override
  Trade create() => Trade();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TradeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TradeState>(value),
    );
  }
}

String _$tradeHash() => r'877aba817381476ffc9c1ebed7f49ee055b2b40c';

abstract class _$Trade extends $Notifier<TradeState> {
  TradeState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TradeState, TradeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TradeState, TradeState>,
              TradeState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
