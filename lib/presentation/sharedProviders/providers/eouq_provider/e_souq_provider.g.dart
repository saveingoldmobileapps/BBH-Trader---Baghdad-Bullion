// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'e_souq_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Esouq)
final esouqProvider = EsouqProvider._();

final class EsouqProvider extends $NotifierProvider<Esouq, EsouqState> {
  EsouqProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'esouqProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$esouqHash();

  @$internal
  @override
  Esouq create() => Esouq();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EsouqState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EsouqState>(value),
    );
  }
}

String _$esouqHash() => r'a10fd33857c0dee11fdf86d4b79d7859a71c0601';

abstract class _$Esouq extends $Notifier<EsouqState> {
  EsouqState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<EsouqState, EsouqState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EsouqState, EsouqState>,
              EsouqState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
