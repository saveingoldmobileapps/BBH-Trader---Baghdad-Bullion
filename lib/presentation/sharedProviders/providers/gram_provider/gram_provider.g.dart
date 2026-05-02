// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gram_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Gram)
final gramProvider = GramProvider._();

final class GramProvider extends $NotifierProvider<Gram, GramState> {
  GramProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gramProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gramHash();

  @$internal
  @override
  Gram create() => Gram();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GramState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GramState>(value),
    );
  }
}

String _$gramHash() => r'186455c7c65877016ec83fe33bb1abd759e8d67c';

abstract class _$Gram extends $Notifier<GramState> {
  GramState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<GramState, GramState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GramState, GramState>,
              GramState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
