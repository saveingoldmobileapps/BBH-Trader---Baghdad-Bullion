// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Loan)
final loanProvider = LoanProvider._();

final class LoanProvider extends $NotifierProvider<Loan, LoanState> {
  LoanProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loanProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loanHash();

  @$internal
  @override
  Loan create() => Loan();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoanState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoanState>(value),
    );
  }
}

String _$loanHash() => r'4ac1a9d7f6662603aa270edaaf21e7dee07976c4';

abstract class _$Loan extends $Notifier<LoanState> {
  LoanState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LoanState, LoanState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LoanState, LoanState>,
              LoanState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
