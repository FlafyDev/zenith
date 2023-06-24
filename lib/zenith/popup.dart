import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zenith/compositor/state/compositor.dart';
import 'package:zenith/zenith/surface.dart';
import 'package:zenith/zenith/window_manager.dart';

class Popup extends HookConsumerWidget {
  const Popup({
    Key? key,
    required this.viewId,
  }) : super(key: key);

  final int viewId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Consumer(builder: (context, ref, child) {
      final parentId = ref.watch(compositorProvider
          .select((e) => e.surfacesState[viewId]!.xdgPopup!.parentId));
      final size = ref.watch(compositorProvider
          .select((e) => e.surfacesState[parentId]!.surface.rect));
      return SizedBox(
        width: size.width,
        height: size.height,
        // width: 200,
        // height: 200,
        child: Stack(
          children: [
            Positioned.fill(
                child: ColoredBox(
              color: Colors.green,
            )),
            Consumer(
              child: Surface(
                viewId: viewId,
                // onEnter: (_) {
                //   ref.read(activeTopLevelProvider.notifier).state = viewId;
                // },
              ),
              builder: (context, ref, child) {
                final xdgSurfaceRect = ref.watch(compositorProvider
                    .select((e) => e.surfacesState[viewId]!.xdgSurface!.rect));
                final xdgPopupRect = ref.watch(compositorProvider
                    .select((e) => e.surfacesState[viewId]!.xdgPopup!.rect));
                final surfaceRect = ref.watch(compositorProvider
                    .select((e) => e.surfacesState[viewId]!.surface.rect));
                return Positioned(
                  top: xdgPopupRect.top - xdgSurfaceRect.top,
                  left: xdgPopupRect.left - xdgSurfaceRect.left,
                  width: surfaceRect.width,
                  height: surfaceRect.height,
                  child: child!,
                );
              },
            ),
          ],
        ),
      );
    });
  }
}
