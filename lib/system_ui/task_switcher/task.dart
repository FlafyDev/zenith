import 'dart:async';

import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zenith/platform_api.dart';
import 'package:zenith/state/task_switcher_state.dart';
import 'package:zenith/state/window_state.dart';
import 'package:zenith/system_ui/task_switcher/fitted_window.dart';
import 'package:zenith/system_ui/task_switcher/task_switcher.dart';
import 'package:zenith/system_ui/virtual_keyboard/with_virtual_keyboard.dart';
import 'package:zenith/widgets/window.dart';

class Task extends HookConsumerWidget {
  final int viewId;
  final VoidCallback switchToTask;

  const Task({
    Key? key,
    required this.viewId,
    required this.switchToTask,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useAnimationController(duration: const Duration(milliseconds: 250));
    final animation = useRef(Tween(begin: 0.0, end: 0.0).animate(controller));

    useEffect(() {
      controller.addListener(() {
        ref.read(taskVerticalPositionProvider(viewId).notifier).state = animation.value.value;
      });
      return null;
    });

    return Consumer(
      builder: (_, WidgetRef ref, Widget? child) {
        final position = ref.watch(taskPositionProvider(viewId));
        final constraints = ref.watch(taskSwitcherState.select((v) => v.constraints));

        return Positioned(
          left: position,
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: child!,
        );
      },
      child: DeferPointer(
        child: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            double position = ref.watch(taskVerticalPositionProvider(viewId));

            return Transform.translate(
              offset: Offset(0, position),
              child: Opacity(
                opacity: (1 - position.abs() / 1000).clamp(0, 1),
                child: child!,
              ),
            );
          },
          child: Consumer(
            builder: (_, WidgetRef ref, Widget? child) {
              final inOverview = ref.watch(taskSwitcherState.select((v) => v.inOverview));

              // Doing my best to not change the depth of the tree to avoid rebuilding the whole subtree.
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: inOverview ? () => switchToTask() : null,
                onVerticalDragUpdate: inOverview
                    ? (DragUpdateDetails details) {
                        ref
                            .read(taskVerticalPositionProvider(viewId).notifier)
                            .update((state) => (state + details.primaryDelta!).clamp(-double.infinity, 0));
                      }
                    : null,
                onVerticalDragDown: inOverview
                    ? (_) {
                        controller.stop();
                      }
                    : null,
                onVerticalDragCancel: inOverview
                    ? () {
                        animation.value = Tween(
                          begin: ref.read(taskVerticalPositionProvider(viewId)),
                          end: 0.0,
                        ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));

                        controller.forward(from: 0);
                      }
                    : null,
                onVerticalDragEnd: inOverview
                    ? (DragEndDetails details) {
                        if (details.primaryVelocity! < -1000) {
                          animation.value = Tween(
                            begin: ref.read(taskVerticalPositionProvider(viewId)),
                            end: -1000.0,
                          ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));

                          PlatformApi.closeView(viewId);
                        } else {
                          animation.value = Tween(
                            begin: ref.read(taskVerticalPositionProvider(viewId)),
                            end: 0.0,
                          ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));
                        }
                        controller.forward(from: 0);
                      }
                    : null,
                child: IgnorePointer(
                  ignoring: inOverview,
                  child: Listener(
                    onPointerDown: !inOverview ? (_) => _moveTaskToTheEnd(ref) : (_) {},
                    child: child,
                  ),
                ),
              );
            },
            child: Consumer(
              builder: (_, WidgetRef ref, Widget? child) {
                final virtualKeyboardKey = ref.watch(windowState(viewId).select((v) => v.virtualKeyboardKey));
                return WithVirtualKeyboard(
                  key: virtualKeyboardKey,
                  viewId: viewId,
                  child: child!,
                );
              },
              child: Consumer(
                builder: (_, WidgetRef ref, __) {
                  final widget = ref.watch(windowWidget(viewId));
                  return FittedWindow(
                    alignment: Alignment.topCenter,
                    window: widget,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _moveTaskToTheEnd(WidgetRef ref) async {
    if (ref.read(taskList).last == viewId) {
      return;
    }
    final notifier = ref.read(taskSwitcherState.notifier);
    notifier.disableUserControl = true;
    // Move the task to the end after the animations have finished.
    await _untilAnimationsStopped(ref);
    // moveCurrentTaskToEnd();
    // jumpToLastTask();
    notifier.disableUserControl = false;
  }
}

Future<void> _untilAnimationsStopped(WidgetRef ref) {
  final completer = Completer<void>();

  if (!ref.read(taskSwitcherState).areAnimationsPlaying) {
    completer.complete();
  } else {
    late ProviderSubscription<bool> subscription;
    subscription = ref.listenManual(
      taskSwitcherState.select((v) => v.areAnimationsPlaying),
      (_, bool animationsPlaying) {
        if (!animationsPlaying) {
          subscription.close();
          completer.complete();
        }
      },
    );
  }
  return completer.future;
}
