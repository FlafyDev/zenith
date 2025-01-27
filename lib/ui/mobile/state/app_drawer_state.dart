import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_drawer_state.freezed.dart';

final appDrawerStateProvider = StateProvider(
  (ref) => const AppDrawerState(
    /// The drawer is in a state where a drag can be engaged, e.g. the drawer is fully scrolled at the top.
    draggable: false,

    /// The user is actively dragging the drawer.
    dragging: false,

    /// You can interact with the drawer and taps won't just go though it.
    interactable: false,

    /// The finger velocity when the drag ends.
    dragVelocity: 0,

    /// 0 means the drawer is fully open.
    /// Equal to slideDistance when it's fully closed.
    offset: 300,

    /// The amount the user has to drag to open the drawer.
    slideDistance: 300,

    /// Event to notify the drawer to initiate the closing animations.
    /// Just assigning a new Object() will do the trick because 2 different Object instances will always be unequal.
    closePanel: Object(),
  ),
);

@freezed
class AppDrawerState with _$AppDrawerState {
  const factory AppDrawerState({
    required bool draggable,
    required bool dragging,
    required bool interactable,
    required double dragVelocity,
    required double offset,
    required double slideDistance,
    required Object closePanel,
  }) = _AppDrawerState;
}
