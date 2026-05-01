// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NewsAll)
final newsAllProvider = NewsAllProvider._();

final class NewsAllProvider extends $NotifierProvider<NewsAll, NewsAllState> {
  NewsAllProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'newsAllProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$newsAllHash();

  @$internal
  @override
  NewsAll create() => NewsAll();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NewsAllState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NewsAllState>(value),
    );
  }
}

String _$newsAllHash() => r'1b3ed65a4064420f75e127280e96afcefc52b5e5';

abstract class _$NewsAll extends $Notifier<NewsAllState> {
  NewsAllState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<NewsAllState, NewsAllState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NewsAllState, NewsAllState>,
              NewsAllState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
