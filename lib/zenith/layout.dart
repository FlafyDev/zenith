import 'dart:ui';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zenith/compositor/state/compositor.dart';

abstract class Layout {
  Layout();
}

class LayoutSurfaceData {
  final Rect rect;
  final int zIndex;
  final bool active;

  const LayoutSurfaceData({
    required this.rect,
    required this.zIndex,
    required this.active,
  });

  LayoutSurfaceData copyWith({
    Rect? rect,
    int? zIndex,
    bool? active,
  }) {
    return LayoutSurfaceData(
      rect: rect ?? this.rect,
      zIndex: zIndex ?? this.zIndex,
      active: active ?? this.active,
    );
  }
}

// class RegularLayout extends Layout {
//   RegularLayout(super.compNotifier);
//
//   @override
//   LayoutSurfaceData getSurfaceData(int viewId) {
//     throw UnimplementedError();
//   }
//
//   @override
//   void onMouseIn(int viewId) {
//     // TODO: implement onMouseIn
//   }
//
//   @override
//   void onMouseOut(int viewId) {
//     // TODO: implement onMouseOut
//   }
//
//   @override
//   void onSurfaceAdded(int viewId) {
//     // TODO: implement onSurfaceAdded
//   }
//
//   @override
//   void onSurfaceRemoved(int viewId) {
//     // TODO: implement onSurfaceRemoved
//   }
// }

abstract class LayoutNotifier
    extends StateNotifier<Map<int, LayoutSurfaceData>> {
  LayoutNotifier(this.compNotifier) : super({});

  final CompositorNotifier compNotifier;

  void onMouseIn(int viewId);
  void onMouseOut(int viewId);
  void onSurfaceAdded(int viewId);
  void onSurfaceRemoved(int viewId);
}

class RegularLayoutNotifier extends LayoutNotifier {
  RegularLayoutNotifier(super.compNotifier);


  @override
  void onMouseIn(int viewId) {
    state = {
      ...state,
      viewId: state[viewId]!.copyWith(active: true),
    };
  }

  @override
  void onMouseOut(int viewId) {
    state = {
      ...state,
      viewId: state[viewId]!.copyWith(active: false),
    };
  }

  @override
  void onSurfaceAdded(int viewId) {
    state = {
      ...state,
      viewId: const LayoutSurfaceData(
        rect: Rect.fromLTWH(0, 0, 200, 200),
        zIndex: 0,
        active: false,
      ),
    };
  }

  @override
  void onSurfaceRemoved(int viewId) {
    state = {...state}..remove(viewId);
  }
}
