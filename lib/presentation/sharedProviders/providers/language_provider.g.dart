// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'language_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Language)
final languageProvider = LanguageProvider._();

final class LanguageProvider
    extends $NotifierProvider<Language, LanguageState> {
  LanguageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'languageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$languageHash();

  @$internal
  @override
  Language create() => Language();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LanguageState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LanguageState>(value),
    );
  }
}

String _$languageHash() => r'bbb1fc45d32c3f17ad9fc43c0639a6873c167ba0';

abstract class _$Language extends $Notifier<LanguageState> {
  LanguageState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LanguageState, LanguageState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LanguageState, LanguageState>,
              LanguageState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
