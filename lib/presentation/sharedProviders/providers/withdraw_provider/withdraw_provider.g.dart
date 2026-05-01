// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'withdraw_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Withdraw)
final withdrawProvider = WithdrawProvider._();

final class WithdrawProvider
    extends $NotifierProvider<Withdraw, WithdrawalState> {
  WithdrawProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'withdrawProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$withdrawHash();

  @$internal
  @override
  Withdraw create() => Withdraw();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WithdrawalState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WithdrawalState>(value),
    );
  }
}

String _$withdrawHash() => r'c757a4f1634a2fca04792f8e8f230a5ceece2f59';

abstract class _$Withdraw extends $Notifier<WithdrawalState> {
  WithdrawalState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<WithdrawalState, WithdrawalState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WithdrawalState, WithdrawalState>,
              WithdrawalState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
