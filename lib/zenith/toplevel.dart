import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zenith/compositor/state/compositor.dart';
import 'package:zenith/zenith/surface.dart';
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
        Surface(
          viewId: viewId,
          onEnter: (_) {
            ref.read(activeTopLevelProvider.notifier).state = viewId;
          },
        ),
        // if (active)
        //   Consumer(builder: (context, ref, child) {
        //     final rect = ref.watch(compositorProvider.select(
        //         (e) => e.surfacesState[viewId]!.xdgSurface!.rect));
        //     return Positioned(
        //       width: rect.width,
        //       height: rect.height,
        //       child: IgnorePointer(
        //         child: DecoratedBox(
        //           decoration: BoxDecoration(
        //             border: Border.all(
        //               color: Colors.green,
        //               width: 2,
        //             ),
        //           ),
        //         ),
        //       ),
        //     );
        //   }),
      ],
    );
  }
}
