import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenith/ui/mobile/state/app_drawer_state.dart';
import 'package:zenith/ui/mobile/app_drawer/app_grid.dart';

class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({super.key});

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Animation? _slideAnimation;
  final _scrollController = ScrollController();

  var _velocityTracker = VelocityTracker.withKind(PointerDeviceKind.touch);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    ref.listenManual(appDrawerStateProvider.select((value) => value.dragging), (bool? previous, bool next) {
      if (next) {
        cancelAnimations();
      } else {
        double dragVelocity = ref.read(appDrawerStateProvider).dragVelocity / 100;
        double offset = ref.read(appDrawerStateProvider).offset;
        double slideDistance = ref.read(appDrawerStateProvider).slideDistance;

        if (dragVelocity.abs() > 5) {
          if (dragVelocity.isNegative) {
            animateOpening(dragVelocity.abs());
          } else {
            animateClosing(dragVelocity.abs());
          }
        } else {
          if (offset <= slideDistance / 2) {
            animateOpening(dragVelocity.abs());
          } else {
            animateClosing(dragVelocity.abs());
          }
        }
      }
    });

    ref.listenManual(appDrawerStateProvider.select((value) => value.closePanel), (_, __) {
      animateClosing(1);
    });
  }

  void cancelAnimations() {
    _slideAnimation?.removeListener(_updateOffset);
    _slideAnimation = null;
  }

  void animateOpening(double velocity) {
    ref.read(appDrawerStateProvider.notifier).update((state) => state.copyWith(interactable: true));
    cancelAnimations();
    animateTo(0, velocity);
  }

  void animateClosing(double velocity) {
    ref.read(appDrawerStateProvider.notifier).update((state) => state.copyWith(interactable: false));
    cancelAnimations();
    animateTo(ref.read(appDrawerStateProvider).slideDistance, velocity);
  }

  void animateTo(double target, double velocity) {
    _slideAnimation = _animationController.drive(Tween(
      begin: ref.read(appDrawerStateProvider).offset,
      end: target,
    ))
      ..addListener(_updateOffset);
    _animationController
      ..reset()
      ..fling(velocity: velocity);
  }

  void _updateOffset() {
    ref.read(appDrawerStateProvider.notifier).update((state) => state.copyWith(offset: _slideAnimation!.value));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, WidgetRef ref, Widget? child) {
        bool interactable = ref.watch(appDrawerStateProvider.select((value) => value.interactable));
        double offset = ref.watch(appDrawerStateProvider.select((value) => value.offset));
        double slideDistance = ref.watch(appDrawerStateProvider.select((value) => value.slideDistance));

        return IgnorePointer(
          ignoring: !interactable,
          child: Opacity(
            opacity: 1 - offset / slideDistance,
            child: child,
          ),
        );
      },
      child: Consumer(
        builder: (_, WidgetRef ref, Widget? child) {
          return Transform.translate(
            offset: Offset(0, ref.watch(appDrawerStateProvider.select((value) => value.offset))),
            child: child,
          );
        },
        // Can't use a GestureDetector because the GridView will always win the arena.
        child: Listener(
          onPointerDown: (e) {
            _velocityTracker = VelocityTracker.withKind(PointerDeviceKind.touch);
            _velocityTracker.addPosition(e.timeStamp, e.localPosition);
          },
          onPointerMove: (e) {
            final appDrawerState = ref.read(appDrawerStateProvider);

            if (appDrawerState.draggable) {
              ref.read(appDrawerStateProvider.notifier).update((state) => state.copyWith(
                    dragging: true,
                    offset: (state.offset + e.localDelta.dy).clamp(0, appDrawerState.slideDistance),
                  ));
              _velocityTracker.addPosition(e.timeStamp, e.localPosition);
            }
          },
          onPointerUp: (e) {
            _velocityTracker.addPosition(e.timeStamp, e.localPosition);

            final doesntScroll =
                _scrollController.position.extentBefore == 0 && _scrollController.position.extentAfter == 0;

            ref.read(appDrawerStateProvider.notifier).update(
                  (state) => state.copyWith(
                    dragging: false,
                    draggable: doesntScroll ? true : false,
                    dragVelocity: _velocityTracker.getVelocity().pixelsPerSecond.dy,
                  ),
                );
          },
          child: Material(
            color: Colors.black.withOpacity(0.8),
            child: Column(
              children: [
                Expanded(
                  child: AppDrawerScrollNotificationListener(
                    child: AppGrid(scrollController: _scrollController),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppDrawerScrollNotificationListener extends ConsumerStatefulWidget {
  final Widget child;

  const AppDrawerScrollNotificationListener({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AppDrawerScrollNotificationListener> createState() => _AppDrawerScrollNotificationListenerState();
}

class _AppDrawerScrollNotificationListenerState extends ConsumerState<AppDrawerScrollNotificationListener> {
  var _startDragging = false;

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (Notification notification) {
        if (notification is ScrollMetricsNotification) {
          // When there are few items in the list and the view is not scrollable,
          // usual scroll notifications like start, update, and overscroll are not sent anymore.
          final metrics = notification.metrics;
          if (metrics.extentBefore == 0.0 && metrics.extentAfter == 0.0) {
            ref.read(appDrawerStateProvider.notifier).update((state) => state.copyWith(draggable: true));
            return true;
          }
        }

        if (notification is ScrollStartNotification) {
          _startDragging = notification.metrics.pixels == 0;
          ref.read(appDrawerStateProvider.notifier).update((state) => state.copyWith(draggable: false));
          return true;
        }

        if (notification is OverscrollNotification && _startDragging) {
          if (notification.dragDetails != null && notification.overscroll.isNegative) {
            ref.read(appDrawerStateProvider.notifier).update((state) => state.copyWith(draggable: true));
            return true;
          }
        }
        return false;
      },
      child: widget.child,
    );
  }
}
