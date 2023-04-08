import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'xdg_popup_state.freezed.dart';

@freezed
class XdgPopupState with _$XdgPopupState {
  const factory XdgPopupState({
    required int parentId,
    required Rect rect,
  }) = _XdgPopupState;

  factory XdgPopupState.fromJson(Map<String, Object?> json) {
    return XdgPopupState(
      parentId: json['parent_id'] as int,
      rect: Rect.fromLTWH(
        (json['x'] as int).toDouble(),
        (json['y'] as int).toDouble(),
        (json['width'] as int).toDouble(),
        (json['height'] as int).toDouble(),
      ),
    );
  }
}
