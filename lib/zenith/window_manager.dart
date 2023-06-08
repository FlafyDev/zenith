import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indexed/indexed.dart';
import 'package:zenith/compositor/state/compositor.dart';
import 'package:zenith/compositor/widgets/surface.dart';
import 'package:zenith/zenith/layout.dart';
import 'package:zenith/zenith/toplevel.dart';

final layoutProvider =
    StateNotifierProvider<LayoutNotifier, Map<int, LayoutSurfaceData>>((ref) {
  return RegularLayoutNotifier(ref.watch(compositorProvider.notifier));
});

final surfaceDataProvider =
    StateProvider.autoDispose.family<LayoutSurfaceData, int>((ref, id) {
  return LayoutSurfaceData(
    rect: ref.read(compositorProvider
        .select((e) => e.surfacesState[id]!.xdgSurface!.rect)),
    zIndex: 0,
    active: false,
  );
});

final toplevelsZIndexProvider = StateProvider<List<int>>((ref) {
  return [];
});

class WindowManager extends HookConsumerWidget {
  const WindowManager({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topLevels =
        ref.watch(compositorProvider.select((e) => e.mappedXdgTopLevels));
    final orderedTopLevels = ref.watch(toplevelsZIndexProvider); 
    // useEffect(() {
    //   final newTopLevels = topLevels.where((e) => prevTopLevels == null || !prevTopLevels.contains(e));
    //   for (final id in newTopLevels) {
    //     ref.read(layoutProvider.notifier).onSurfaceAdded(id);
    //   }
    // }, [topLevels]);
    ref.listen<List<int>?>(
        compositorProvider.select((e) => e.mappedXdgTopLevels), (prev, next) {
      final newTopLevels =
          next!.where((e) => prev == null || !prev.contains(e));
      final removedTopLevels = prev!.where((e) => !next.contains(e));
      for (final id in newTopLevels) {
        ref.read(toplevelsZIndexProvider.notifier).update((s) => [...s, id]);
        // ref.read(layoutProvider.notifier).onSurfaceAdded(id);
      }
      for (final id in removedTopLevels) {
        ref
            .read(toplevelsZIndexProvider.notifier)
            .update((s) => [...s]..remove(id));
        // ref.read(layoutProvider.notifier).onSurfaceAdded(id);
      }
    });

    return Stack(
      children: orderedTopLevels
          .map(
            (id) => Consumer(
              builder: (context, ref, child) {
                final layoutData = ref.watch(surfaceDataProvider(id));
                return Toplevel(viewId: id, active: layoutData.active);
              },
            ),
          )
          .toList(),
    );
  }
}
