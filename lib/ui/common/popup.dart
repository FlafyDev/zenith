import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenith/ui/common/popup_stack.dart';
import 'package:zenith/ui/common/state/zenith_surface_state.dart';
import 'package:zenith/ui/common/state/zenith_xdg_popup_state.dart';
import 'package:zenith/ui/common/state/zenith_xdg_surface_state.dart';
import 'package:zenith/ui/common/surface.dart';

final popupWidget = StateProvider.family<Popup, int>((ref, int viewId) {
  return Popup(
    key: ref.read(zenithXdgSurfaceStateProvider(viewId)).widgetKey,
    viewId: viewId,
  );
});

class Popup extends StatelessWidget {
  final int viewId;

  const Popup({
    required Key key,
    required this.viewId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _Positioner(
      viewId: viewId,
      child: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          Key key = ref.watch(zenithXdgPopupStateProvider(viewId).select((v) => v.animationsKey));
          return _Animations(
            key: key,
            viewId: viewId,
            child: child!,
          );
        },
        child: Consumer(
          builder: (_, WidgetRef ref, __) {
            return ref.watch(surfaceWidget(viewId));
          },
        ),
      ),
    );
  }
}

class _Positioner extends ConsumerWidget {
  final int viewId;
  final Widget child;

  const _Positioner({
    Key? key,
    required this.viewId,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (_, WidgetRef ref, Widget? child) {
        Offset position = ref.watch(zenithXdgPopupStateProvider(viewId).select((v) => v.position));
        Rect visibleBounds = ref.watch(zenithXdgSurfaceStateProvider(viewId).select((v) => v.visibleBounds));
        int parentId = ref.watch(zenithXdgPopupStateProvider(viewId).select((v) => v.parentViewId));
        // FIXME: cannot use watch because the popup thinks the window is at 0,0 when these bounds change.
        Rect parentVisibleBounds = ref.read(zenithXdgSurfaceStateProvider(parentId).select((v) => v.visibleBounds));

        RenderBox? parentRenderBox = ref
            .watch(zenithSurfaceStateProvider(parentId).select((v) => v.textureKey))
            .currentContext
            ?.findRenderObject() as RenderBox?;
        RenderBox? popupStackRenderBox =
            ref.watch(popupStackGlobalKey).currentContext?.findRenderObject() as RenderBox?;

        Offset offset;
        if (parentRenderBox != null &&
            popupStackRenderBox != null &&
            parentRenderBox.attached &&
            popupStackRenderBox.attached) {
          Offset global = parentRenderBox.localToGlobal(position);
          offset = popupStackRenderBox.globalToLocal(global);
        } else {
          offset = position;
        }

        return Positioned(
          left: offset.dx - visibleBounds.left + parentVisibleBounds.left,
          top: offset.dy - visibleBounds.top + parentVisibleBounds.top,
          child: child!,
        );
      },
      child: Consumer(
        builder: (_, WidgetRef ref, Widget? child) {
          bool isClosing = ref.watch(zenithXdgPopupStateProvider(viewId).select((v) => v.isClosing));
          return IgnorePointer(
            ignoring: isClosing,
            child: child,
          );
        },
        child: child,
      ),
    );
  }
}

class _Animations extends ConsumerStatefulWidget {
  final int viewId;
  final Widget child;

  @override
  ConsumerState<_Animations> createState() => AnimationsState();

  const _Animations({
    Key? key,
    required this.viewId,
    required this.child,
  }) : super(key: key);
}

class AnimationsState extends ConsumerState<_Animations> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        transformHitTests: false,
        position: _offsetAnimation,
        child: widget.child,
      ),
    );
  }

  late final AnimationController controller = AnimationController(
    duration: const Duration(milliseconds: 200),
    reverseDuration: const Duration(milliseconds: 100),
    vsync: this,
  )..forward();

  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: Offset(
      0.0,
      -10.0 / ref.read(zenithSurfaceStateProvider(widget.viewId)).surfaceSize.height,
    ),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: controller,
    curve: Curves.easeOutCubic,
  ));

  late final Animation<double> _fadeAnimation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: controller,
    curve: Curves.easeOutCubic,
  ));

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
