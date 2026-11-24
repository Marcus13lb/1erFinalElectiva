// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(wordList)
final wordListProvider = WordListProvider._();

final class WordListProvider
    extends
        $FunctionalProvider<
          AsyncValue<BuiltSet<String>>,
          BuiltSet<String>,
          FutureOr<BuiltSet<String>>
        >
    with $FutureModifier<BuiltSet<String>>, $FutureProvider<BuiltSet<String>> {
  WordListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wordListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wordListHash();

  @$internal
  @override
  $FutureProviderElement<BuiltSet<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BuiltSet<String>> create(Ref ref) {
    return wordList(ref);
  }
}

String _$wordListHash() => r'dc9ea046d014e1e7aef2fff03cb0fe3c3715972f';

@ProviderFor(Size)
final sizeProvider = SizeProvider._();

final class SizeProvider extends $NotifierProvider<Size, CrosswordSize> {
  SizeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sizeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sizeHash();

  @$internal
  @override
  Size create() => Size();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CrosswordSize value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CrosswordSize>(value),
    );
  }
}

String _$sizeHash() => r'eb133b42965790fb371fcf8cd0f69b29b5199947';

abstract class _$Size extends $Notifier<CrosswordSize> {
  CrosswordSize build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CrosswordSize, CrosswordSize>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CrosswordSize, CrosswordSize>,
              CrosswordSize,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(workQueue)
final workQueueProvider = WorkQueueProvider._();

final class WorkQueueProvider
    extends
        $FunctionalProvider<
          AsyncValue<model.WorkQueue>,
          model.WorkQueue,
          Stream<model.WorkQueue>
        >
    with $FutureModifier<model.WorkQueue>, $StreamProvider<model.WorkQueue> {
  WorkQueueProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workQueueProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workQueueHash();

  @$internal
  @override
  $StreamProviderElement<model.WorkQueue> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<model.WorkQueue> create(Ref ref) {
    return workQueue(ref);
  }
}

String _$workQueueHash() => r'f6c52bc797b052c493ec3cc4d13a405ef424528c';

@ProviderFor(StartTime)
final startTimeProvider = StartTimeProvider._();

final class StartTimeProvider extends $NotifierProvider<StartTime, DateTime?> {
  StartTimeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'startTimeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$startTimeHash();

  @$internal
  @override
  StartTime create() => StartTime();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime?>(value),
    );
  }
}

String _$startTimeHash() => r'aced96ef5d2ace2a4e9bee398a0165f3fef010d2';

abstract class _$StartTime extends $Notifier<DateTime?> {
  DateTime? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DateTime?, DateTime?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime?, DateTime?>,
              DateTime?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(EndTime)
final endTimeProvider = EndTimeProvider._();

final class EndTimeProvider extends $NotifierProvider<EndTime, DateTime?> {
  EndTimeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'endTimeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$endTimeHash();

  @$internal
  @override
  EndTime create() => EndTime();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime?>(value),
    );
  }
}

String _$endTimeHash() => r'9804a7e9db2a257f235f452610f275de8f97b998';

abstract class _$EndTime extends $Notifier<DateTime?> {
  DateTime? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DateTime?, DateTime?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime?, DateTime?>,
              DateTime?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ShowDisplayInfo)
final showDisplayInfoProvider = ShowDisplayInfoProvider._();

final class ShowDisplayInfoProvider
    extends $NotifierProvider<ShowDisplayInfo, bool> {
  ShowDisplayInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'showDisplayInfoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$showDisplayInfoHash();

  @$internal
  @override
  ShowDisplayInfo create() => ShowDisplayInfo();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$showDisplayInfoHash() => r'b2431424d49a736527acd8bbffc93d2abf4935a2';

abstract class _$ShowDisplayInfo extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(expectedRemainingTime)
final expectedRemainingTimeProvider = ExpectedRemainingTimeProvider._();

final class ExpectedRemainingTimeProvider
    extends $FunctionalProvider<Duration, Duration, Duration>
    with $Provider<Duration> {
  ExpectedRemainingTimeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expectedRemainingTimeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expectedRemainingTimeHash();

  @$internal
  @override
  $ProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Duration create(Ref ref) {
    return expectedRemainingTime(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$expectedRemainingTimeHash() =>
    r'7646901d41429f1e15827fccb7a8277f65cc4d04';

@ProviderFor(DisplayInfo)
final displayInfoProvider = DisplayInfoProvider._();

final class DisplayInfoProvider
    extends $NotifierProvider<DisplayInfo, model.DisplayInfo> {
  DisplayInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'displayInfoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$displayInfoHash();

  @$internal
  @override
  DisplayInfo create() => DisplayInfo();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(model.DisplayInfo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<model.DisplayInfo>(value),
    );
  }
}

String _$displayInfoHash() => r'91df3ea17517c435dec88a7244a0fcf7ade9ab7f';

abstract class _$DisplayInfo extends $Notifier<model.DisplayInfo> {
  model.DisplayInfo build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<model.DisplayInfo, model.DisplayInfo>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<model.DisplayInfo, model.DisplayInfo>,
              model.DisplayInfo,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
