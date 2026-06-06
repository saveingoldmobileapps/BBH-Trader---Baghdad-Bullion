// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shufti_pro_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ShuftiPro)
final shuftiProProvider = ShuftiProProvider._();

final class ShuftiProProvider
    extends $NotifierProvider<ShuftiPro, ShuftiProState> {
  ShuftiProProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shuftiProProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shuftiProHash();

  @$internal
  @override
  ShuftiPro create() => ShuftiPro();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShuftiProState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShuftiProState>(value),
    );
  }
}

String _$shuftiProHash() => r'fa15ebabc5590ccd264557c104f21b66eccb5ca9';

abstract class _$ShuftiPro extends $Notifier<ShuftiProState> {
  ShuftiProState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ShuftiProState, ShuftiProState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ShuftiProState, ShuftiProState>,
              ShuftiProState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
