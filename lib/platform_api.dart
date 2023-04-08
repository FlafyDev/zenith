import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenith/compositor/state/compositor.dart';
import 'package:zenith/compositor/state/xdg_surface_state.dart';

import 'compositor/state/surface_commit_state.dart';

final compositorPlatformApi = Provider((ref) {
  const channel = MethodChannel("platform");

  void commitSurface(SurfaceCommitState commit) {
    compositorProviderEdit(ref, (compositor) {
      return compositor.copyWith(
        surfacesState: {
          ...compositor.surfacesState,
          commit.viewId: commit,
        },
      );
    });
  }

  void mapXdgSurface(SurfaceCommitState state) {
    switch (state.xdgSurface!.role) {
      case XdgSurfaceRole.none:
        if (kDebugMode) {
          throw Exception("XdgSurfaceRole.none is not a valid role");
        }
        break;
      case XdgSurfaceRole.toplevel:
        compositorProviderEdit(ref, (compositor) {
          return compositor.copyWith(
            mappedXdgSurfaces: [...compositor.mappedXdgSurfaces, state.viewId],
          );
        });
        break;
      case XdgSurfaceRole.popup:
        break;
    }
  }

  void unmapXdgSurface(SurfaceCommitState state) {
    switch (state.xdgSurface!.role) {
      case XdgSurfaceRole.none:
        if (kDebugMode) {
          throw Exception("XdgSurfaceRole.none is not a valid role");
        }
        break;
      case XdgSurfaceRole.toplevel:
        break;
      case XdgSurfaceRole.popup:
        break;
    }
  }

  channel.setMethodCallHandler((call) async {
    print(call.method);
    final args =
        (call.arguments as Map<Object?, Object?>).cast<String, dynamic>();
    switch (call.method) {
      case "commit_surface":
        commitSurface(SurfaceCommitState.fromJson(args));
        break;
      case "map_xdg_surface":
        mapXdgSurface(ref
            .read(compositorProvider.notifier)
            .state
            .surfacesState[args["view_id"] as int]!);
        break;
      case "unmap_xdg_surface":
        unmapXdgSurface(ref
            .read(compositorProvider.notifier)
            .state
            .surfacesState[call.arguments as int]!);
        break;
      case "map_subsurface":
        break;
      case "unmap_subsurface":
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
  });

  return channel;
});

// Map<String, dynamic> convertMap(Map<dynamic, dynamic> map) {
//   for (final key in map.keys) {
//     if (map[key] is Map) {
//       map[key] = convertMap(map[key]);
//     }
//   } 
//   return Map<String, dynamic>.from(map);
// }
