import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zenith/platform_api.dart';
import 'package:zenith/ui/desktop/server_side_decorations/server_side_decorations.dart';

part 'zenith_xdg_toplevel_state.freezed.dart';

final zenithXdgToplevelStateProvider = StateNotifierProvider.family<
    ZenithXdgToplevelStateNotifier,
    ZenithXdgToplevelState,
    int>((ref, int viewId) {
  return ZenithXdgToplevelStateNotifier(ref, viewId);
});

@freezed
class ZenithXdgToplevelState with _$ZenithXdgToplevelState {
  const factory ZenithXdgToplevelState({
    required bool visible,
    required Key virtualKeyboardKey,
    required Object interactiveMoveRequested,
    required ResizeEdgeObject interactiveResizeRequested,
  }) = _ZenithXdgToplevelState;
}

class ZenithXdgToplevelStateNotifier
    extends StateNotifier<ZenithXdgToplevelState> {
  final Ref _ref;
  final int _viewId;

  ZenithXdgToplevelStateNotifier(this._ref, this._viewId)
      : super(
          ZenithXdgToplevelState(
            visible: true,
            virtualKeyboardKey: GlobalKey(),
            interactiveMoveRequested: Object(),
            interactiveResizeRequested: ResizeEdgeObject(ResizeEdge.top),
          ),
        );

  set visible(bool value) {
    if (value != state.visible) {
      PlatformApi.changeWindowVisibility(_viewId, value);
      state = state.copyWith(visible: value);
    }
  }

  void maximize(bool value) {
    PlatformApi.maximizeWindow(_viewId, value);
  }

  void resize(int width, int height) {
    PlatformApi.resizeWindow(_viewId, width, height);
  }

  void requestInteractiveMove() {
    state = state.copyWith(
      interactiveMoveRequested: Object(),
    );
  }

  void requestInteractiveResize(ResizeEdge edge) {
    state = state.copyWith(
      interactiveResizeRequested: ResizeEdgeObject(edge),
    );
  }
}

class ResizeEdgeObject {
  final ResizeEdge edge;

  ResizeEdgeObject(this.edge);
}
