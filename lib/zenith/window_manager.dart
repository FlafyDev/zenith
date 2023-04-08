import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zenith/compositor/state/compositor.dart';
import 'package:zenith/compositor/widgets/surface.dart';

class WindowManager extends HookConsumerWidget {
  const WindowManager({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mappedXdgSurfacesId =
        ref.watch(compositorProvider.select((e) => e.mappedXdgSurfaces));

    return Stack(
      children: mappedXdgSurfacesId
          .map((e) => Positioned(
                left: 100,
                top: 100,
                child: Surface(viewId: e),
              ))
          .toList(),
    );
  }
}
