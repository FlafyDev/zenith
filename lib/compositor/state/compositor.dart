import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:zenith/compositor/state/surface_commit_state.dart';
import 'package:zenith/compositor/state/xdg_surface_state.dart';

part 'compositor.freezed.dart';

class CompositorNotifier extends StateNotifier<Compositor> {
  CompositorNotifier()
      : super(const Compositor(
          surfacesState: {},
          mappedXdgTopLevels: [],
          mappedXdgPopups: [],
          mappedSubsurfaces: [],
        )) {
    channel.setMethodCallHandler((call) async {
      try {
        print(call.method);
        final args =
            (call.arguments as Map<Object?, Object?>).cast<String, dynamic>();
        switch (call.method) {
          case "commit_surface":
            commitSurface(SurfaceCommitState.fromJson(args));
            break;
          case "map_xdg_surface":
            mapXdgSurface(state.surfacesState[args["view_id"] as int]!);
            break;
          case "unmap_xdg_surface":
            unmapXdgSurface(state.surfacesState[args["view_id"] as int]!);
            break;
          case "map_subsurface":
            mapSubsurface(args["view_id"] as int);
            break;
          case "unmap_subsurface":
            unmapSubsurface(args["view_id"] as int);
            break;
          case "send_text_input_event":
            break;
          case "interactive_move":
            break;
          case "interactive_resize":
            break;
          case "set_title":
            // final surfaceCommitState =
            //     surfaceCommitStateProvider(call.arguments["view_id"] as int);
            // ref.read(surfaceCommitState.notifier).commit(ref
            //     .read(surfaceCommitState)
            //     .copyWith(toplevelTitle: call.arguments["title"] as String));
            break;
          case "set_app_id":
            // final surfaceCommitState =
            //     surfaceCommitStateProvider(call.arguments["view_id"] as int);
            // ref.read(surfaceCommitState.notifier).commit(ref
            //     .read(surfaceCommitState)
            //     .copyWith(toplevelAppId: call.arguments["app_id"] as String));
            break;
          default:
            throw PlatformException(
              code: "unknown_method",
              message: "Unknown method ${call.method}",
            );
        }
      } catch (e, s) {
        print("ERROR");
        print(s);
        print(e);
      }
    });
  }

  static const channel = MethodChannel("platform");

  void commitSurface(SurfaceCommitState commit) {
    print(commit.viewId);
    print(commit.surface.subsurfacesAbove);
    state = state.copyWith(
      surfacesState: {
        ...state.surfacesState,
        commit.viewId: commit,
      },
    );
  }

  void mapXdgSurface(SurfaceCommitState surfaceState) {
    switch (surfaceState.xdgSurface!.role) {
      case XdgSurfaceRole.none:
        if (kDebugMode) {
          throw Exception("XdgSurfaceRole.none is not a valid role");
        }
        break;
      case XdgSurfaceRole.toplevel:
        state = state.copyWith(
          mappedXdgTopLevels: [
            ...state.mappedXdgTopLevels,
            surfaceState.viewId,
          ],
        );
        break;
      case XdgSurfaceRole.popup:
        state = state.copyWith(
          mappedXdgPopups: [...state.mappedXdgPopups, surfaceState.viewId],
        );
        break;
    }
  }

  void unmapXdgSurface(SurfaceCommitState surfaceState) {
    switch (surfaceState.xdgSurface!.role) {
      case XdgSurfaceRole.none:
        if (kDebugMode) {
          throw Exception("XdgSurfaceRole.none is not a valid role");
        }
        break;
      case XdgSurfaceRole.toplevel:
        state = state.copyWith(
          mappedXdgTopLevels: state.mappedXdgTopLevels
              .where((e) => e != surfaceState.viewId)
              .toList(),
        );
        break;
      case XdgSurfaceRole.popup:
        state = state.copyWith(
          mappedXdgPopups: state.mappedXdgPopups
              .where((e) => e != surfaceState.viewId)
              .toList(),
        );
        break;
    }
  }

  void mapSubsurface(int viewId) {
    state = state.copyWith(
      mappedSubsurfaces: [...state.mappedSubsurfaces, viewId],
    );
  }

  void unmapSubsurface(int viewId) {
    state = state.copyWith(
      mappedSubsurfaces:
          state.mappedSubsurfaces.where((e) => e != viewId).toList(),
    );
  }

  Future<void> sendMouseButtonEventToView(int button, bool isPressed) {
    // One might find surprising that the view id is not sent to the platform. This is because the view id is only sent
    // when the pointer moves, and when a button event happens, the platform already knows which view it hovers.
    return channel.invokeMethod<void>("mouse_button_event", {
      "button": button,
      "is_pressed": isPressed,
    });
  }

  Future<void> activateWindow(int viewId) {
    return channel.invokeMethod('activate_window', viewId);
  }

  Future<void> insertText(int viewId, String text) {
    return channel.invokeMethod('insert_text', {
      "view_id": viewId,
      "text": text,
    });
  }

  Future<void> pointerHoverView(int viewId, Offset position) {
    return channel.invokeMethod("pointer_hover", {
      "view_id": viewId,
      "x": position.dx,
      "y": position.dy,
    });
  }


  Future<void> sendMouseButtonEvent(int button, bool isPressed) {
    // One might find surprising that the view id is not sent to the platform. This is because the view id is only sent
    // when the pointer moves, and when a button event happens, the platform already knows which view it hovers.
    return channel.invokeMethod("mouse_button_event", {
      "button": button,
      "is_pressed": isPressed,
    });
  }
}

final compositorProvider =
    StateNotifierProvider<CompositorNotifier, Compositor>((ref) {
  return CompositorNotifier();
});

@freezed
class Compositor with _$Compositor {
  const factory Compositor({
    required Map<int, SurfaceCommitState> surfacesState,
    required List<int> mappedXdgTopLevels,
    required List<int> mappedXdgPopups,
    required List<int> mappedSubsurfaces,
  }) = _Compositor;
}
