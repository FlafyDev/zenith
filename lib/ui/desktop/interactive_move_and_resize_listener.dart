import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenith/ui/common/state/zenith_xdg_surface_state.dart';
import 'package:zenith/ui/common/state/zenith_xdg_toplevel_state.dart';
import 'package:zenith/ui/desktop/manual_pan_gesture_recognizer.dart';
import 'package:zenith/ui/desktop/state/window_move_provider.dart';
import 'package:zenith/ui/desktop/state/window_resize_provider.dart';
import 'package:zenith/ui/desktop/window.dart';

class InteractiveMoveAndResizeListener extends ConsumerStatefulWidget {
  final int viewId;
  final Widget child;

  const InteractiveMoveAndResizeListener({
    super.key,
    required this.viewId,
    required this.child,
  });

  @override
  ConsumerState<InteractiveMoveAndResizeListener> createState() => _InteractiveMoveAndResizeListenerState();
}

class _InteractiveMoveAndResizeListenerState extends ConsumerState<InteractiveMoveAndResizeListener> {
  ProviderSubscription? interactiveMoveSubscription;
  ProviderSubscription? interactiveResizeSubscription;

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        ManualPanGestureRecognizer: GestureRecognizerFactoryWithHandlers<ManualPanGestureRecognizer>(
          () => ManualPanGestureRecognizer(),
          _initializer,
        ),
      },
      child: widget.child,
    );
  }

  void _initializer(ManualPanGestureRecognizer instance) {
    var windowMove = ref.read(windowMoveProvider(widget.viewId).notifier);
    var windowResize = ref.read(windowResizeProvider(widget.viewId).notifier);

    instance.dragStartBehavior = DragStartBehavior.down;
    instance.onDown = (_) {
      windowMove.startPotentialMove();
      windowResize.startPotentialResize();

      interactiveMoveSubscription = ref.listenManual(
        zenithXdgToplevelStateProvider(widget.viewId).select((v) => v.interactiveMoveRequested),
        (_, __) {
          var windowPosition = ref.read(windowPositionStateProvider(widget.viewId));
          windowMove.startMove(windowPosition);

          // We can start moving the window.
          // Cancel all other GestureDetectors in the arena.
          instance.claimVictory();
        },
      );

      interactiveResizeSubscription = ref.listenManual<ResizeEdgeObject>(
        zenithXdgToplevelStateProvider(widget.viewId).select((v) => v.interactiveResizeRequested),
        (_, ResizeEdgeObject? resizeEdge) {
          if (resizeEdge == null) {
            return;
          }

          Size size = ref.read(zenithXdgSurfaceStateProvider(widget.viewId)).visibleBounds.size;
          windowResize.startResize(resizeEdge.edge, size);

          // We can start resizing the window.
          // Cancel all other GestureDetectors in the arena.
          instance.claimVictory();
        },
      );
    };
    instance.onUpdate = (DragUpdateDetails event) {
      windowMove.move(event.delta);
      windowResize.resize(event.delta);
    };
    instance.onEnd = (_) {
      windowMove.endMove();
      windowResize.endResize();
      interactiveMoveSubscription?.close();
      interactiveResizeSubscription?.close();
    };
    instance.onCancel = () {
      windowMove.cancelMove();
      windowResize.cancelResize();
      interactiveMoveSubscription?.close();
      interactiveResizeSubscription?.close();
    };
  }
}
