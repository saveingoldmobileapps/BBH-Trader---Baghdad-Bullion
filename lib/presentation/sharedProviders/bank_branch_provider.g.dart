// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bank_branch_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BankBranch)
final bankBranchProvider = BankBranchProvider._();

final class BankBranchProvider
    extends $NotifierProvider<BankBranch, BankBranchState> {
  BankBranchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bankBranchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bankBranchHash();

  @$internal
  @override
  BankBranch create() => BankBranch();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BankBranchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BankBranchState>(value),
    );
  }
}

String _$bankBranchHash() => r'f404778878661b82e17c61ccc3d49770c0609d26';

abstract class _$BankBranch extends $Notifier<BankBranchState> {
  BankBranchState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BankBranchState, BankBranchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BankBranchState, BankBranchState>,
              BankBranchState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
