import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zenith/compositor/state/compositor.dart';
import 'package:zenith/compositor/widgets/surface.dart';
import 'package:zenith/zenith/window_manager.dart';

class Toplevel extends HookConsumerWidget {
  const Toplevel({
    Key? key,
    required this.viewId,
    required this.active,
  }) : super(key: key);

  final int viewId;
  final bool active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Consumer(
          child: Surface(
            viewId: viewId,
            onEnter: (_) {
              ref
                  .read(toplevelsZIndexProvider.notifier)
                  .update((state) => [...state]
                    ..remove(viewId)
                    ..add(viewId));
              ref.read(compositorProvider.notifier).activateWindow(viewId);
            },
            onExit: (_) {
              ref
                  .read(surfaceDataProvider(viewId).notifier)
                  .update((state) => state.copyWith(active: false));
            },
          ),
          builder: (context, ref, child) {
            final size = ref.watch(compositorProvider
                .select((e) => e.surfacesState[viewId]!.surface.rect.size));
            return Positioned(
              width: size.width,
              height: size.height,
              child: child!,
            );
          },
        ),
        Consumer(builder: (context, ref, child) {
          final rect = ref.watch(compositorProvider
              .select((e) => e.surfacesState[viewId]!.xdgSurface!.rect));
          return Positioned.fromRect(
            rect: rect,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.green,
                    width: 2,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
