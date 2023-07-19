import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zenith/compositor/state/subsurface_state.dart';

part 'surface_state.freezed.dart';

enum SurfaceRole {
  none,
  xdgSurface,
  subsurface,
  xwaylandSurface,
}

@freezed
class SurfaceState with _$SurfaceState {
  const factory SurfaceState({
    required SurfaceRole role,
    required int textureId,
    required Rect rect,
    required int scale,
    required List<SubsurfaceState> subsurfacesBelow,
    required List<SubsurfaceState> subsurfacesAbove,
    required Rect inputRegion,
  }) = _SurfaceState;

  factory SurfaceState.fromJson(Map<String, Object?> json) {
    return SurfaceState(
      role: SurfaceRole.values[json['role'] as int],
      textureId: json['textureId'] as int,
      rect: Rect.fromLTWH(
        (json['x'] as int).toDouble(),
        (json['y'] as int).toDouble(),
        (json['width'] as int).toDouble(),
        (json['height'] as int).toDouble(),
      ),
      scale: json['scale'] as int,
      subsurfacesBelow: (json['subsurfaces_below'] as List<Object?>)
          .map((e) =>
              SubsurfaceState.fromJson((e as Map).cast<String, Object?>()))
          .toList(),
      subsurfacesAbove: (json['subsurfaces_above'] as List<Object?>)
          .map((e) =>
              SubsurfaceState.fromJson((e as Map).cast<String, Object?>()))
          .toList(),
      inputRegion: Rect.fromLTRB(
        ((json['input_region'] as Map)['x1'] as int).toDouble(),
        ((json['input_region'] as Map)['y1'] as int).toDouble(),
        ((json['input_region'] as Map)['x2'] as int).toDouble(),
        ((json['input_region'] as Map)['y2'] as int).toDouble(),
      ),
    );
  }
}
