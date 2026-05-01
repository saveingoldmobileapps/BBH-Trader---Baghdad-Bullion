// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AlertAll)
final alertAllProvider = AlertAllProvider._();

final class AlertAllProvider extends $NotifierProvider<AlertAll, AlertState> {
  AlertAllProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'alertAllProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$alertAllHash();

  @$internal
  @override
  AlertAll create() => AlertAll();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AlertState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AlertState>(value),
    );
  }
}

String _$alertAllHash() => r'bab746c180968cf6e0a8d80c621699c803eaed1d';

abstract class _$AlertAll extends $Notifier<AlertState> {
  AlertState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AlertState, AlertState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AlertState, AlertState>,
              AlertState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
