import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zenith/compositor/state/compositor.dart';
import 'package:zenith/compositor/state/subsurface_state.dart';
import 'package:zenith/util/raw_gesture_recognizer.dart';

class Surface extends HookConsumerWidget {
  const Surface({
    required this.viewId,
    this.onEnter,
    this.onExit,
    Key? key,
  }) : super(key: key);

  final int viewId;
  final void Function(PointerEnterEvent)? onEnter;
  final void Function(PointerExitEvent)? onExit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FIXME: Performance issue?
    if (!ref
        .watch(compositorProvider.select((e) => e.surfacesState))
        .containsKey(viewId)) {
      return Container();
    }

    final rect = ref.watch(compositorProvider
        .select((e) => e.surfacesState[viewId]!.surface.rect));
    final subsurfacesBelow = ref.watch(compositorProvider
        .select((e) => e.surfacesState[viewId]!.surface.subsurfacesBelow));
    final subsurfacesAbove = ref.watch(compositorProvider
        .select((e) => e.surfacesState[viewId]!.surface.subsurfacesAbove));

    return SizedBox(
      width: rect.width,
      height: rect.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ...(subsurfacesBelow.map((e) => _Subsurface(subsurface: e)).toList()),
          _ViewInputListener(
            onEnter: onEnter,
            onExit: onExit,
            viewId: viewId,
            child: Consumer(builder: (context, ref, _) {
              final textureId = ref.watch(compositorProvider
                  .select((e) => e.surfacesState[viewId]!.surface.textureId));
              return Texture(textureId: textureId);
            }),
          ),
          ...(subsurfacesAbove.map((e) => _Subsurface(subsurface: e)).toList()),
        ],
      ),
    );
  }
}

class _Subsurface extends HookConsumerWidget {
  const _Subsurface({
    required this.subsurface,
    Key? key,
  }) : super(key: key);

  final SubsurfaceState subsurface;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      left: subsurface.position.dx,
      top: subsurface.position.dy,
      child: Surface(viewId: subsurface.id),
    );
  }
}

class _ViewInputListener extends HookConsumerWidget {
  const _ViewInputListener({
    super.key,
    required this.viewId,
    required this.child,
    this.onEnter,
    this.onExit,
  });

  final void Function(PointerEnterEvent)? onEnter;
  final void Function(PointerExitEvent)? onExit;
  final int viewId;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inputRegion = ref.watch(compositorProvider
        .select((e) => e.surfacesState[viewId]!.surface.inputRegion));
    final mouseButtonTracker = ref.watch(mouseButtonTrackerProvider);

    Future<void> sendMouseButtons(int buttons) async {
      MouseButtonEvent? e = mouseButtonTracker.trackButtonState(buttons);
      if (e != null) {
        ref.read(compositorProvider.notifier).sendMouseButtonEvent(
            e.button, e.state == MouseButtonState.pressed);
      }
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IgnorePointer(
          child: child,
        ),
        Positioned.fromRect(
          rect: inputRegion,
          // child: Container(color: Colors.black),
          child: Consumer(builder: (context, ref, child) {
            return RawGestureDetector(
              gestures: <Type, GestureRecognizerFactory>{
                RawGestureRecognizer:
                    GestureRecognizerFactoryWithHandlers<RawGestureRecognizer>(
                  () => RawGestureRecognizer(),
                  (RawGestureRecognizer instance) {
                    instance.onPointerDown = (PointerDownEvent event) async {
                      // TODO: event.position is actually the local position. Don't try to access
                      // event.localPosition because it contains the wrong value.
                      var position = event.position + inputRegion.topLeft;

                      if (event.kind == PointerDeviceKind.mouse) {
                        ref
                            .read(compositorProvider.notifier)
                            .pointerHoverView(viewId, position);
                        sendMouseButtons(event.buttons);
                        // await _pointerMoved(position);
                        // await _sendMouseButtonsToPlatform(event.buttons);
                        // pointerFocusManager.startPotentialDrag();
                      } else if (event.kind == PointerDeviceKind.touch) {
                        // await PlatformApi.touchDown(
                        //     widget.viewId, event.pointer, position);
                      }
                    };
                    instance.onPointerMove = (PointerMoveEvent event) async {
                      var position = event.position + inputRegion.topLeft;

                      if (event.kind == PointerDeviceKind.mouse) {
                        sendMouseButtons(event.buttons);
                        ref
                            .read(compositorProvider.notifier)
                            .pointerHoverView(viewId, position);
                        // ref
                        //     .read(compositorProvider.notifier)
                        //     .sendMouseButtonEvent(event.buttons, true);
                        // ref
                        //     .read(compositorProvider.notifier)
                        //     .pointerHoverView(viewId, position);
                        // If a button is being pressed while another one is already down, it's considered a move event, not a down event.
                        // await _sendMouseButtonsToPlatform(event.buttons);
                        // await _pointerMoved(position);
                      } else if (event.kind == PointerDeviceKind.touch) {
                        // await PlatformApi.touchMotion(event.pointer, position);
                      }
                    };
                    instance.onPointerUp = (PointerUpEvent event) async {
                      if (event.kind == PointerDeviceKind.mouse) {
                        sendMouseButtons(event.buttons);
                        // await _sendMouseButtonsToPlatform(event.buttons);
                        // pointerFocusManager.stopPotentialDrag();
                      } else if (event.kind == PointerDeviceKind.touch) {
                        // await PlatformApi.touchUp(event.pointer);
                      }
                    };
                    instance.onPointerCancel =
                        (PointerCancelEvent event) async {
                      if (event.kind == PointerDeviceKind.mouse) {
                        // await _sendMouseButtonsToPlatform(event.buttons);
                        // pointerFocusManager.stopPotentialDrag();
                      } else if (event.kind == PointerDeviceKind.touch) {
                        // await PlatformApi.touchCancel(event.pointer);
                      }
                    };
                  },
                ),
              },
              child: Listener(
                onPointerHover: (PointerHoverEvent event) {
                  if (event.kind == PointerDeviceKind.mouse) {
                    var position = event.localPosition + inputRegion.topLeft;
                    ref
                        .read(compositorProvider.notifier)
                        .pointerHoverView(viewId, position);
                    // _pointerMoved(position);
                  }
                },
                // child: Container(color: Colors.red),
                child: MouseRegion(
                  onEnter: onEnter,
                  onExit: onExit,
                  // onExit: (_) => pointerFocusManager.exitSurface(),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

final mouseButtonTrackerProvider = Provider((ref) => MouseButtonTracker());

/// When receiving a pointer event in the Listener widget, we can only have a bitmap of all pressed mouse buttons, and
/// not the button that has been pressed or released. This class tracks changes between such bitmaps and returns the
/// difference in the form of a MouseButtonEvent object.
class MouseButtonTracker {
  int buttons = 0;

  MouseButtonEvent? trackButtonState(int newButtons) {
    if (buttons == newButtons) {
      return null;
    }
    var button = buttons ^ newButtons;
    var state = newButtons & button != 0
        ? MouseButtonState.pressed
        : MouseButtonState.released;
    buttons = newButtons;
    return MouseButtonEvent(button, state);
  }
}

enum MouseButtonState {
  pressed,
  released,
}

class MouseButtonEvent {
  final int button;
  final MouseButtonState state;

  const MouseButtonEvent(this.button, this.state);

  MouseButtonEvent copyWith({
    int? button,
    MouseButtonState? state,
  }) {
    return MouseButtonEvent(button ?? this.button, state ?? this.state);
  }
}
