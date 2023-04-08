import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zenith/compositor/state/compositor.dart';
import 'package:zenith/compositor/state/subsurface_state.dart';

class Surface extends HookConsumerWidget {
  const Surface({
    required this.viewId,
    Key? key,
  }) : super(key: key);

  final int viewId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          Consumer(builder: (context, ref, _) {
            final textureId = ref.watch(compositorProvider
                .select((e) => e.surfacesState[viewId]!.surface.textureId));
            return Texture(textureId: textureId);
          }),
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
