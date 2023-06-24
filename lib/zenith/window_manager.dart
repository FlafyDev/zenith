import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zenith/compositor/state/compositor.dart';
import 'package:zenith/zenith/layout.dart';
import 'package:zenith/zenith/surface.dart';
import 'package:collection/collection.dart';

final layoutProvider =
    StateNotifierProvider<LayoutNotifier, Map<int, LayoutSurfaceData>>((ref) {
  return RegularLayoutNotifier(ref.watch(compositorProvider.notifier));
});

// final surfaceDataProvider =
//     StateProvider.autoDispose.family<LayoutSurfaceData, int>((ref, id) {
//   return LayoutSurfaceData(
//     rect: ref.read(compositorProvider
//         .select((e) => e.surfacesState[id]!.xdgSurface!.rect)),
//     zIndex: 0,
//     active: false,
//   );
// });

final activeTopLevelProvider = StateProvider<int?>((ref) {
  return null;
});

final orderedTopLevelsProvider = StateProvider<List<int>>((ref) {
  return [];
});

final topLevelsPositions = StateProvider<Map<int, Offset>>((ref) => {});

class WindowManager extends HookConsumerWidget {
  const WindowManager({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positions = useValueNotifier<Map<int, Offset>>({});
    final orderedTopLevels = ref.watch(orderedTopLevelsProvider);
    final popups =
        ref.watch(compositorProvider.select((e) => e.mappedXdgPopups));

    ref.listen<List<int>?>(
        compositorProvider.select((e) => e.mappedXdgTopLevels), (prev, next) {
      final newTopLevels =
          next!.where((e) => prev == null || !prev.contains(e));
      final removedTopLevels = prev!.where((e) => !next.contains(e));
      for (final id in newTopLevels) {
        positions.value = {...positions.value, id: const Offset(100, 100)};
        ref.read(orderedTopLevelsProvider.notifier).update((s) => [...s, id]);
      }
      for (final id in removedTopLevels) {
        positions.value = {...positions.value}..remove(id);
        ref
            .read(orderedTopLevelsProvider.notifier)
            .update((s) => [...s]..remove(id));
      }
    });

    ref.listen<int?>(activeTopLevelProvider, (prev, id) {
      if (id == null) {
        ref
            .read(orderedTopLevelsProvider.notifier)
            .update((state) => [...state]..remove(id));
        // TODO: figure out how to deactivate a window.
        // ref.read(compositorProvider.notifier).activateWindow(null);
        return;
      }

      ref.read(compositorProvider.notifier).activateWindow(id);
      ref.read(orderedTopLevelsProvider.notifier).update((state) => [...state]
        ..remove(id)
        ..add(id));
    });

    final tops =
        ref.read(compositorProvider.select((e) => e.mappedXdgTopLevels));
    final pops = ref.read(compositorProvider.select((e) => e.mappedXdgPopups));

    // if (tops.isNotEmpty && pops.isNotEmpty) {
    //   print(
    //       'xdgsurfaces - popupsurfaces: ${ref.read(compositorProvider.select((e) => e.surfacesState[tops.first]!.xdgSurface))} --- ${ref.read(compositorProvider.select((e) => e.surfacesState[pops.first]!.xdgSurface))}');
    // }
    print(positions);

    return Stack(
      children: [
        Positioned(
          width: 1000,
          height: 800,
          child: Stack(
            children: [
              ...orderedTopLevels.map(
                (id) => ValueListenableBuilder<Map<int, Offset>>(
                  key: ValueKey(id),
                  valueListenable: positions,
                  builder: (context, positionsVal, child) {
                    return _TopLevel(
                      id: id,
                      offset: positionsVal[id] ?? Offset.zero,
                    );
                  },
                ),
              ),
              ...popups.map(
                (id) => Consumer(
                  builder: (context, ref, child) {
                    final parentId = ref.watch(compositorProvider.select(
                        (e) => e.surfacesState[id]!.xdgPopup!.parentId));
                    final offset = positions.value[parentId];
                    final xdgSurfaceRect = ref.watch(compositorProvider
                        .select((e) => e.surfacesState[id]!.xdgSurface!.rect));
                    final xdgPopupRect = ref.watch(compositorProvider
                        .select((e) => e.surfacesState[id]!.xdgPopup!.rect));
                    final surfaceRect = ref.watch(compositorProvider
                        .select((e) => e.surfacesState[id]!.surface.rect));
                    return Positioned(
                      left: (offset?.dx ?? 0) +
                          xdgPopupRect.left -
                          xdgSurfaceRect.left,
                      top: (offset?.dy ?? 0) +
                          xdgPopupRect.top -
                          xdgSurfaceRect.top,
                      width: surfaceRect.width,
                      height: surfaceRect.height,
                      child: Surface(
                        viewId: id,
                        // onEnter: (_) {
                        //   ref.read(activeTopLevelProvider.notifier).state = viewId;
                        // },
                      ),
                    );
                  },
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: TextButton(
                    onPressed: () async {
                      Process.run('nautilus', []);

                      await Future.delayed(Duration(seconds: 3));

                      final viewId = ref.read(compositorProvider
                          .select((e) => e.surfacesState.keys.last));
                      print(ref.read(compositorProvider
                          .select((e) => e.surfacesState.keys.length)));
                      // positions.value = {
                      //   ...positions.value,
                      //   viewId: Offset(200 + Random().nextDouble() * 300,
                      //       200 + Random().nextDouble() * 300)
                      // };
                      await ref
                          .read(compositorProvider.notifier)
                          .resizeWindow(viewId, 300, 300);
                    },
                    child: Text('Run foot'),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class _TopLevel extends HookConsumerWidget {
  const _TopLevel({
    super.key,
    required this.id,
    required this.offset,
  });

  final int id;
  final Offset offset;

  @override
  Widget build(context, ref) {
    final xdgRect = ref.watch(compositorProvider
        .select((e) => e.surfacesState[id]!.xdgSurface!.rect));
    final surfaceSize = ref.watch(compositorProvider
        .select((e) => e.surfacesState[id]!.surface.rect.size));
    // final active =
    //     ref.watch(activeTopLevelProvider.select((activeId) => activeId == id));

    // Offset
    final offsetAC =
        useAnimationController(duration: const Duration(milliseconds: 3000));
    final offsetTween = useRef(Tween<Offset>(begin: offset, end: offset));
    useEffect(() {
      offsetTween.value = Tween(
        begin: offsetTween.value.transform(offsetAC.value),
        end: offset,
      );
      offsetAC.reset();
      offsetAC.animateTo(1); // , curve: const Cubic(0, 0.75, 0.15, 1)
      return;
    }, [offset]);

    // Size
    final sizeAC =
        useAnimationController(duration: const Duration(milliseconds: 3000));
    final sizeTween = useRef(Tween<Size>(begin: surfaceSize, end: surfaceSize));
    useEffect(() {
      sizeTween.value = Tween(
        begin: sizeTween.value.transform(sizeAC.value),
        end: surfaceSize,
      );
      sizeAC.reset();
      sizeAC.animateTo(1);
      return;
    }, [surfaceSize]);

    print('${ref.read(compositorProvider.select((e) => e.surfacesState[id]!.toplevelDecoration))}');

    return AnimatedBuilder(
      animation: Listenable.merge([offsetAC]),
      builder: (context, child) {
        final offset = offsetTween.value.transform(offsetAC.value);
        return Positioned(
          left: offset.dx.round() - xdgRect.left,
          top: offset.dy.round() - xdgRect.top,
          width: surfaceSize.width,
          height: surfaceSize.height,
          child: child!,
        );
      },
      child: Listener(
        onPointerMove: (event) {
          if (true) return;
          // positions.value = {
          //   ...positions.value,
          //   id: positions.value[id]! + event.delta,
          // };
        },
        child: Stack(
          children: [
            // Positioned(
            //   left: xdgRect.left,
            //   top: xdgRect.top,
            //   width: surfaceSize.width,
            //   height: surfaceSize.height,
            //   child: ClipRect(
            //     child: BackdropFilter(
            //       filter: ImageFilter.blur(
            //         sigmaX: 100,
            //         sigmaY: 100,
            //       ),
            //       child: Container(color: Colors.transparent),
            //     ),
            //   ),
            // ),
            AnimatedBuilder(
              animation: sizeAC,
              builder: (context, child) {
                final size = sizeTween.value.transform(sizeAC.value);
                return Positioned(
                  width: size.width,
                  height: size.height,
                  child: Surface(
                    viewId: id,
                    onEnter: (_) {
                      ref.read(activeTopLevelProvider.notifier).state = id;
                    },
                  ),
                );
              },
            ),
            // if (false)
            //   Positioned(
            //     left: xdgRect.left,
            //     top: xdgRect.top,
            //     width: xdgRect.width,
            //     height: xdgRect.height,
            //     child: const MouseRegion(),
            //   ),
          ],
        ),
      ),
    );
  }
}
