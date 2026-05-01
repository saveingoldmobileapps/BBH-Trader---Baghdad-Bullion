// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_transfer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DirectTransfer)
final directTransferProvider = DirectTransferProvider._();

final class DirectTransferProvider
    extends $NotifierProvider<DirectTransfer, DirectTransferState> {
  DirectTransferProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'directTransferProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$directTransferHash();

  @$internal
  @override
  DirectTransfer create() => DirectTransfer();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DirectTransferState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DirectTransferState>(value),
    );
  }
}

String _$directTransferHash() => r'1dc40ee8fe765459e658292369a198214d051504';

abstract class _$DirectTransfer extends $Notifier<DirectTransferState> {
  DirectTransferState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DirectTransferState, DirectTransferState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DirectTransferState, DirectTransferState>,
              DirectTransferState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
