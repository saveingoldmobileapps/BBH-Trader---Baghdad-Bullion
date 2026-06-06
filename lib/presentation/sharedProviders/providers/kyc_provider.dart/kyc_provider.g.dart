// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyc_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(KYC)
final kYCProvider = KYCProvider._();

final class KYCProvider extends $NotifierProvider<KYC, KYCState> {
  KYCProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kYCProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kYCHash();

  @$internal
  @override
  KYC create() => KYC();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KYCState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KYCState>(value),
    );
  }
}

String _$kYCHash() => r'2c3ce45cfe5b4e3c0fc0f2ea0a44993dc83d18a1';

abstract class _$KYC extends $Notifier<KYCState> {
  KYCState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<KYCState, KYCState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<KYCState, KYCState>,
              KYCState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
