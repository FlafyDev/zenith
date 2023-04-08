import 'dart:ui';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zenith/compositor/state/surface_commit_state.dart';

part 'compositor.freezed.dart';

final compositorProvider = StateProvider<Compositor>((ref) {
  return const Compositor(
    surfacesState: {},
    mappedXdgSurfaces: [],
  );
});

void compositorProviderEdit(
    Ref ref, Compositor Function(Compositor compositor) callback) {
  ref.read(compositorProvider.notifier).state =
      callback(ref.read(compositorProvider.notifier).state);
}

@freezed
class Compositor with _$Compositor {
  const factory Compositor({
    required Map<int, SurfaceCommitState> surfacesState,
    required List<int> mappedXdgSurfaces,
  }) = _Compositor;
}
