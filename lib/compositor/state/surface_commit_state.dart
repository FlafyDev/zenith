import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zenith/compositor/state/surface_state.dart';
import 'package:zenith/compositor/state/xdg_popup_state.dart';
import 'package:zenith/compositor/state/xdg_surface_state.dart';

part 'surface_commit_state.freezed.dart';

// final surfaceCommitStateProvider = StateNotifierProvider.family<
//     SurfaceCommitStateNotifier, SurfaceCommitState, int>((ref, int viewId) {
//   return SurfaceCommitStateNotifier(viewId);
// });
//
// class SurfaceCommitStateNotifier extends StateNotifier<SurfaceCommitState> {
//   final int viewId;
//
//   SurfaceCommitStateNotifier(this.viewId)
//       : super(SurfaceCommitState(
//           viewId: viewId,
//           surface: const SurfaceState(
//             role: SurfaceRole.none,
//             textureId: 0,
//             rect: Rect.zero,
//             scale: 1,
//             subsurfacesBelow: [],
//             subsurfacesAbove: [],
//             inputRegion: Rect.zero,
//           ),
//         ));
//
//   void commit(SurfaceCommitState newState) {
//     state = newState;
//   }
// }

enum ToplevelDecoration {
  none,
  clientSide,
  serverSide,
}

@freezed
class SurfaceCommitState with _$SurfaceCommitState {
  const factory SurfaceCommitState({
    required int viewId,
    required SurfaceState surface,
    XdgSurfaceState? xdgSurface,
    XdgPopupState? xdgPopup,
    ToplevelDecoration? toplevelDecoration,
    String? toplevelTitle,
    String? toplevelAppId,
  }) = _SurfaceCommitState;

  factory SurfaceCommitState.fromJson(Map<String, Object?> json) {
    return SurfaceCommitState(
      viewId: json['view_id'] as int,
      surface: SurfaceState.fromJson(
          (json['surface'] as Map).cast<String, Object?>()),
      xdgSurface: json['xdg_surface'] == null
          ? null
          : XdgSurfaceState.fromJson(
              (json['xdg_surface'] as Map).cast<String, Object?>()),
      xdgPopup: json['xdg_popup'] == null
          ? null
          : XdgPopupState.fromJson(
              (json['xdg_popup'] as Map).cast<String, Object?>()),
      toplevelDecoration: json['toplevel_decoration'] == null
          ? null
          : ToplevelDecoration.values[json['toplevel_decoration'] as int],
      toplevelTitle: json['toplevel_title'] as String?,
      toplevelAppId: json['toplevel_app_id'] as String?,
    );
  }
}
