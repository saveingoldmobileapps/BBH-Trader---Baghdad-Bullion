// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sse_gold_price_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ---------------------------------------------------------------------------
/// RIVERPOD PROVIDER
/// ---------------------------------------------------------------------------

@ProviderFor(goldPrice)
final goldPriceProvider = GoldPriceProvider._();

/// ---------------------------------------------------------------------------
/// RIVERPOD PROVIDER
/// ---------------------------------------------------------------------------

final class GoldPriceProvider
    extends
        $FunctionalProvider<
          AsyncValue<SSEGoldPriceState>,
          SSEGoldPriceState,
          Stream<SSEGoldPriceState>
        >
    with
        $FutureModifier<SSEGoldPriceState>,
        $StreamProvider<SSEGoldPriceState> {
  /// ---------------------------------------------------------------------------
  /// RIVERPOD PROVIDER
  /// ---------------------------------------------------------------------------
  GoldPriceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goldPriceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goldPriceHash();

  @$internal
  @override
  $StreamProviderElement<SSEGoldPriceState> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<SSEGoldPriceState> create(Ref ref) {
    return goldPrice(ref);
  }
}

String _$goldPriceHash() => r'a6bb1d06800af3db9ec61d86457528e4159659e2';
