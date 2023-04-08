import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zenith/compositor/state/subsurface_state.dart';

part 'xdg_surface_state.freezed.dart';

enum XdgSurfaceRole {
  none,
  toplevel,
  popup,
}

@freezed
class XdgSurfaceState with _$XdgSurfaceState {
  const factory XdgSurfaceState({
    required XdgSurfaceRole role,
    required Rect rect,
  }) = _XdgSurfaceState;

  factory XdgSurfaceState.fromJson(Map<String, Object?> json) {
    return XdgSurfaceState(
      role: XdgSurfaceRole.values[json['role'] as int],
      rect: Rect.fromLTWH(
        (json['x'] as int).toDouble(),
        (json['y'] as int).toDouble(),
        (json['width'] as int).toDouble(),
        (json['height'] as int).toDouble(),
      ),
    );
  }
}
