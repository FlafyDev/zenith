import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'subsurface_state.freezed.dart';

@freezed
class SubsurfaceState with _$SubsurfaceState {
  const factory SubsurfaceState({
    required int id,
    required Offset position,
  }) = _SubsurfaceState;

  factory SubsurfaceState.fromJson(Map<String, Object?> json) {
    return SubsurfaceState(
      id: json['id'] as int,
      position: Offset(
        (json['x'] as int).toDouble(),
        (json['y'] as int).toDouble(),
      ),
    );
  }
}
